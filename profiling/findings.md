# Profiling Findings

## Approach

- Baseline load came from the JMeter plans in `jmeter/`.
- Runtime sampling used JFR-compatible profiling on the running Spring Boot JVM.
- The generated text files in this folder are derived from `jdk.ExecutionSample` and `jfr summary`.
- `*-hotspots.txt` keeps the request-specific stack excerpts small enough for code review.

## Endpoint Findings

### `/all-student`

- Baseline average response time: `40091.67 ms`
- Sampling shows most request time under Hibernate JDBC execution and entity materialization.
- The code path in `StudentService.getAllStudentsWithCourses()` loads all students, then issues `studentCourseRepository.findByStudentId(student.getId())` inside a loop.
- With 20,000 students, this creates one query for the student list plus one query per student for course mappings.
- The service also creates a brand-new `StudentCourse` object for every returned row even though the repository already returns `StudentCourse`.

### `/highest-gpa`

- Baseline average response time: `34.59 ms`
- Current latency is not catastrophic, but the implementation scales poorly.
- `StudentService.findStudentWithHighestGpa()` calls `studentRepository.findAll()` and scans all rows in memory to return one student.
- Sampling confirms time spent both in the service method and in Hibernate select execution.
- This endpoint is a good candidate for pushing sort and limit into the database.

### `/all-student-name`

- Baseline average response time: `6845.91 ms`
- JFR execution samples show `java.lang.StringConcatHelper` in the hottest stacks for this request path.
- `StudentService.joinStudentNames()` uses `result += ...` inside a loop, which repeatedly allocates new strings as the result grows.
- The endpoint also loads full `Student` entities even though it only needs the `name` column.

## Expected Optimization Direction

- `/all-student`: fetch student-course rows in one query and avoid per-student repository calls.
- `/highest-gpa`: use an ordered query with database-side limiting.
- `/all-student-name`: fetch names only and join with a builder or collector.
