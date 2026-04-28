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

## Progress

- [x] Setup project and PostgreSQL configuration
- [x] Add JMeter baseline
- [ ] Record profiling findings
- [ ] Optimize `/all-student`
- [ ] Optimize `/highest-gpa`
- [ ] Optimize `/all-student-name`
- [ ] Document comparison and reflection
