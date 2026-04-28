# Exercise Profiling

## Project Setup

1. Use JDK 17 or JDK 21.
2. Configure PostgreSQL in `src/main/resources/application.properties`.
3. Run `./mvnw.cmd install`.
4. Run the application with `./mvnw.cmd spring-boot:run` or IntelliJ IDEA.
5. Seed the data:
   - `http://localhost:8080/seed-data-master`
   - `http://localhost:8080/seed-student-course`

This repository was prepared with PostgreSQL defaults:

- Database: `advpro-2024`
- Username: `postgres`
- Password: `my-password`

Optional environment overrides:

- `PROFILING_DB_URL`
- `PROFILING_DB_USERNAME`
- `PROFILING_DB_PASSWORD`

## Running the Application

PowerShell:

```powershell
$env:JAVA_HOME='C:\Program Files\Java\jdk-21'
.\mvnw.cmd spring-boot:run
```

If you want a repo-local PostgreSQL instance instead of a system installation, use the helper scripts in [`scripts/`](scripts).

## Seed Data

After the application is running:

1. Open `http://localhost:8080/seed-data-master`
2. Open `http://localhost:8080/seed-student-course`

## JMeter

Prepare local JMeter:

```powershell
.\scripts\setup-jmeter.ps1
```

Open JMeter GUI:

```powershell
.\tools\jmeter\apache-jmeter-5.6.3\bin\jmeter.bat
```

Run baseline from CLI:

```powershell
.\scripts\run-jmeter.ps1 -TestPlan 'jmeter\all-student-name.jmx' -ResultFile 'jmeter\results\before-all-student-name.jtl' -ReportDir 'jmeter\reports\before-all-student-name' -SummaryFile 'jmeter\results\before-all-student-name-summary.json'
.\scripts\run-jmeter.ps1 -TestPlan 'jmeter\highest-gpa.jmx' -ResultFile 'jmeter\results\before-highest-gpa.jtl' -ReportDir 'jmeter\reports\before-highest-gpa' -SummaryFile 'jmeter\results\before-highest-gpa-summary.json'
```

Additional baseline for `/all-student`:

```powershell
.\scripts\run-jmeter.ps1 -TestPlan 'jmeter\all-student.jmx' -ResultFile 'jmeter\results\before-all-student.jtl' -ReportDir 'jmeter\reports\before-all-student' -SummaryFile 'jmeter\results\before-all-student-summary.json'
```

The CLI runner also generates an HTML dashboard under `jmeter/reports/`, but that folder is treated as local generated output and is not committed.

## Baseline Performance Result

Seeded dataset:

- 20,000 students
- 10 courses
- 2 course mappings per student

Baseline result before optimization:

| Endpoint | Avg response time (ms) | Throughput (req/s) | Error rate | Evidence |
| --- | ---: | ---: | ---: | --- |
| `/all-student-name` | 6845.91 | 2.81 | 0% | `jmeter/results/before-all-student-name.jtl`, `jmeter/results/before-all-student-name-summary.json` |
| `/highest-gpa` | 34.59 | 76.80 | 0% | `jmeter/results/before-highest-gpa.jtl`, `jmeter/results/before-highest-gpa-summary.json` |
| `/all-student` | 40091.67 | 0.05 | 0% | `jmeter/results/before-all-student.jtl`, `jmeter/results/before-all-student-summary.json` |

## Profiling Findings

Profiling evidence is stored under `profiling/` as JFR summaries and execution-sample dumps that can be reviewed without the IntelliJ UI.

| Endpoint | Primary hotspot | Finding | Evidence |
| --- | --- | --- | --- |
| `/all-student` | Hibernate JDBC execution and repeated repository access | `getAllStudentsWithCourses()` loads all students, then calls `findByStudentId()` once per student, which creates an N+1 query pattern and additional object copying. | `profiling/all-student-summary.txt`, `profiling/all-student-hotspots.txt`, `profiling/findings.md` |
| `/highest-gpa` | Full table fetch before in-memory scan | `findStudentWithHighestGpa()` reads the entire `students` table with `findAll()` even though the endpoint only needs one row. | `profiling/highest-gpa-summary.txt`, `profiling/highest-gpa-hotspots.txt`, `profiling/findings.md` |
| `/all-student-name` | Repeated string allocation in request thread | `joinStudentNames()` performs repeated immutable string concatenation, and JFR shows `StringConcatHelper` dominating sampled request stacks. | `profiling/all-student-name-summary.txt`, `profiling/all-student-name-hotspots.txt`, `profiling/findings.md` |

## Optimization Changes

### `/all-student`

- Initial problem: `StudentService.getAllStudentsWithCourses()` loaded all students first, then queried student-course rows once per student, causing an N+1 pattern and unnecessary object recreation.
- Change: added `StudentCourseRepository.findAllWithStudentAndCourse()` with `join fetch` for both `student` and `course`, then returned that list directly from the service.
- Reason: the endpoint only needs the final student-course list, so one joined query is cheaper than one query per student and avoids rebuilding `StudentCourse` objects in Java.
- Result:
  - Before average response time: `40091.67 ms`
  - After average response time: `257.67 ms`
  - Improvement: `99.36%`
  - Throughput before/after: `0.05 req/s` -> `5.77 req/s`
  - Evidence: `jmeter/results/before-all-student-summary.json`, `jmeter/results/after-all-student-summary.json`

### `/highest-gpa`

- Initial problem: `findStudentWithHighestGpa()` fetched the entire `students` table and searched the maximum GPA in application memory.
- Change: added `StudentRepository.findFirstByOrderByGpaDescIdAsc()` and returned it directly from the service.
- Reason: the endpoint only needs one row, so sorting and limiting should happen in the database where the data already lives.
- Result:
  - Before average response time: `34.59 ms`
  - After average response time: `4.04 ms`
  - Improvement: `88.32%`
  - Throughput before/after: `76.80 req/s` -> `84.48 req/s`
  - Evidence: `jmeter/results/before-highest-gpa-summary.json`, `jmeter/results/after-highest-gpa-summary.json`

### `/all-student-name`

- Initial problem: `joinStudentNames()` loaded full `Student` entities and built the response with repeated `result += ...` concatenation.
- Change: added `StudentRepository.findAllNamesOrderById()` to fetch only the `name` column, then joined the names with `String.join(", ", ...)`.
- Reason: the endpoint only needs student names, so there is no value in hydrating entire entities or reallocating the whole response string on every loop iteration.
- Result:
  - Before average response time: `6845.91 ms`
  - After average response time: `12.26 ms`
  - Improvement: `99.82%`
  - Throughput before/after: `2.81 req/s` -> `83.00 req/s`
  - Evidence: `jmeter/results/before-all-student-name-summary.json`, `jmeter/results/after-all-student-name-summary.json`

## Progress

- [x] Setup project and PostgreSQL configuration
- [x] Add JMeter baseline
- [x] Record profiling findings
- [x] Optimize `/all-student`
- [x] Optimize `/highest-gpa`
- [x] Optimize `/all-student-name`
- [ ] Document comparison and reflection
