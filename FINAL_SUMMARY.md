# Final Summary

## Branch

- `milestone-1-project-setup`
- `milestone-2-initial-jmeter-tests`
- `milestone-3-intellij-profiling`
- `milestone-4-optimize-all-student`
- `milestone-5-optimize-highest-gpa`
- `milestone-6-optimize-all-student-name`
- `milestone-7-readme-reflection`
- `milestone-8-readme-screenshots`

## PR

- `#1` `[Setup] - Configure PostgreSQL and project properties`
- `#2` `[Testing] - Add initial JMeter performance baseline`
- `#3` `[Profiling] - Record endpoint profiling findings`
- `#4` `[Refactoring] - Optimize all student query`
- `#5` `[Refactoring] - Optimize highest GPA endpoint`
- `#6` `[Refactoring] - Optimize all student name endpoint`
- `#7` `[Docs] - Add performance comparison and reflection`
- `#8` `[Docs] - Add screenshot evidence to README`

## Important Commit

- `a79413b` `[Setup] - Configure PostgreSQL and project properties`
- `caed6b3` `[Testing] - Add initial JMeter performance baseline`
- `1afafd3` `[Profiling] - Record endpoint profiling findings`
- `77d956a` `[Refactoring] - Optimize all student query`
- `83b3958` `[Refactoring] - Optimize highest GPA endpoint`
- `7d0c594` `[Refactoring] - Optimize all student name endpoint`
- `fbee2e2` `[Docs] - Add performance comparison and reflection`
- `096585d` `[Docs] - Add screenshot evidence to README`

## Optimization Changes

- `/all-student`: replaced the N+1 access pattern with a single `join fetch` query and removed unnecessary `StudentCourse` object recreation.
- `/highest-gpa`: replaced `findAll()` plus in-memory scanning with `findFirstByOrderByGpaDescIdAsc()`.
- `/all-student-name`: fetched only `name` values and joined them with `String.join(...)` instead of repeated string concatenation.

## Screenshot Evidence

- `docs/screenshots/jmeter-test-plan-all-student-name.png`
- `docs/screenshots/jmeter-cli-highest-gpa.png`
- `docs/screenshots/before-all-student-name-dashboard.png`
- `docs/screenshots/after-all-student-name-dashboard.png`

## Before vs After

| Endpoint | Before avg (ms) | After avg (ms) | Improvement | Throughput before | Throughput after |
| --- | ---: | ---: | ---: | ---: | ---: |
| `/all-student` | 40091.67 | 248.50 | 99.38% | 0.05 | 5.91 |
| `/highest-gpa` | 34.59 | 4.03 | 88.35% | 76.80 | 84.78 |
| `/all-student-name` | 6845.91 | 8.96 | 99.87% | 2.81 | 82.66 |

## Added Result and Evidence Files

### JMeter Plans

- `jmeter/all-student.jmx`
- `jmeter/highest-gpa.jmx`
- `jmeter/all-student-name.jmx`

### JMeter Results

- `jmeter/results/before-all-student.jtl`
- `jmeter/results/before-all-student-summary.json`
- `jmeter/results/before-highest-gpa.jtl`
- `jmeter/results/before-highest-gpa-summary.json`
- `jmeter/results/before-all-student-name.jtl`
- `jmeter/results/before-all-student-name-summary.json`
- `jmeter/results/after-all-student.jtl`
- `jmeter/results/after-all-student-summary.json`
- `jmeter/results/after-highest-gpa.jtl`
- `jmeter/results/after-highest-gpa-summary.json`
- `jmeter/results/after-all-student-name.jtl`
- `jmeter/results/after-all-student-name-summary.json`

### Profiling Evidence

- `profiling/findings.md`
- `profiling/all-student-summary.txt`
- `profiling/all-student-hotspots.txt`
- `profiling/highest-gpa-summary.txt`
- `profiling/highest-gpa-hotspots.txt`
- `profiling/all-student-name-summary.txt`
- `profiling/all-student-name-hotspots.txt`

### Helper Scripts

- `scripts/setup-portable-postgres.ps1`
- `scripts/start-local-postgres.ps1`
- `scripts/stop-local-postgres.ps1`
- `scripts/setup-jmeter.ps1`
- `scripts/run-jmeter.ps1`
- `scripts/summarize-jmeter.ps1`
- `scripts/capture-jfr-profile.ps1`
- `scripts/run-app.ps1`

## Final Build and Test Status

- `main` is clean and synced with `origin/main`
- `./mvnw.cmd test` passed
- `./mvnw.cmd install` passed
- the final application build runs successfully
- endpoint verification returned `200` from `http://localhost:8080/highest-gpa`

## Git Merge Status

- all milestone changes were merged through Pull Requests
- merge strategy used regular merge commits
- no rebase merge, squash merge, or fast-forward-only merge was used
