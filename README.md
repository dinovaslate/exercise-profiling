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

## Progress

- [x] Setup project and PostgreSQL configuration
- [ ] Add JMeter baseline
- [ ] Record profiling findings
- [ ] Optimize `/all-student`
- [ ] Optimize `/highest-gpa`
- [ ] Optimize `/all-student-name`
- [ ] Document comparison and reflection
