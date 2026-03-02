# Java/Kotlin Recommendations

> Reference for aicodeprep analysis. See main SKILL.md for usage.

## Build Tools

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Gradle 8+** | Modern | Apache-2.0 | Fast, Kotlin DSL, flexible |
| Maven | Established | Apache-2.0 | XML config, very stable |
| Bazel | Modern | Apache-2.0 | Google, for huge monorepos |

**Gradle Features:**
- **Version Catalogs** - Centralized dependency versions
- **Kotlin DSL** - Type-safe build scripts
- **Build Cache** - Faster incremental builds

**Recommendation:**
- Modern preference → **Gradle 8+ (Kotlin DSL)**
- Established preference → **Maven** (simpler, widely understood)
- Huge monorepos → **Bazel**

## Dependency Management

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Version Catalogs** | Modern | - | Gradle 7+, centralized |
| buildSrc | Established | - | Pre-version catalogs |
| BOM (Maven/Gradle) | Established | - | Version alignment |

**Recommendation:** **Version Catalogs** (Gradle) or **BOM** (Maven)

## Linting & Static Analysis

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Spotless** | Modern | Apache-2.0 | Multi-format, Gradle plugin |
| **Checkstyle** | Established | LGPL-2.1 | Java style checker |
| **SpotBugs** | Established | LGPL-2.1 | Bug detection (FindBugs successor) |
| **Error Prone** | Modern | Apache-2.0 | Google, compile-time checks |
| PMD | Established | BSD-4 | Code analysis |
| detekt | Modern | Apache-2.0 | Kotlin-specific |
| ktlint | Modern | MIT | Kotlin linter/formatter |

**Note:** Checkstyle, SpotBugs use LGPL - check licensing requirements

**Recommendation:**
- Java → **Spotless + SpotBugs + Error Prone**
- Kotlin → **Spotless + detekt**
- Formatting only → **Spotless** or **ktlint**

## Formatting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Spotless** | Standard | Apache-2.0 | Supports google-java-format, ktfmt |
| google-java-format | Modern | Apache-2.0 | Google's style |
| ktfmt | Modern | Apache-2.0 | Kotlin formatter |
| palantir-java-format | Modern | Apache-2.0 | Palantir's style |

**Recommendation:** **Spotless** with **google-java-format** or **ktfmt**

## Testing

### Unit Testing

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **JUnit 5** | Standard | EPL-2.0 | Modern Java testing |
| JUnit 4 | Legacy | EPL-1.0 | Still widely used |
| TestNG | Established | Apache-2.0 | More features |
| Kotest | Modern | Apache-2.0 | Kotlin-native |
| Spock | Modern | Apache-2.0 | Groovy, BDD-style |

### Mocking

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Mockito** | Standard | MIT | Most popular Java mocking |
| **MockK** | Modern | Apache-2.0 | Kotlin-native mocking |
| WireMock | Standard | Apache-2.0 | HTTP service mocking |
| Testcontainers | Modern | MIT | Docker containers in tests |
| EasyMock | Established | Apache-2.0 | Alternative to Mockito |

### Assertions

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **AssertJ** | Standard | Apache-2.0 | Fluent assertions |
| Hamcrest | Established | BSD-3 | Matcher library |
| Truth | Modern | Apache-2.0 | Google |

### Coverage

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **JaCoCo** | Standard | EPL-2.0 | Most popular |
| Kover | Modern | Apache-2.0 | Kotlin-specific |

**Recommendation:**
- Java → **JUnit 5 + Mockito + AssertJ + JaCoCo**
- Kotlin → **JUnit 5** or **Kotest** + **MockK**
- Integration → **Testcontainers + WireMock**

## CLI Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **picocli** | Standard | Apache-2.0 | Feature-rich, GraalVM native |
| JCommander | Established | Apache-2.0 | Simpler |
| Airline | Modern | Apache-2.0 | Git-style commands |
| clikt | Modern | Apache-2.0 | Kotlin-native |
| kotlinx-cli | Modern | Apache-2.0 | JetBrains |

**Recommendation:**
- Java → **picocli**
- Kotlin → **clikt** or **picocli**
- Simple needs → **JCommander**

## Web Frameworks

### Java

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Spring Boot** | Standard | Apache-2.0 | Most popular, full ecosystem |
| Quarkus | Modern | Apache-2.0 | Cloud-native, fast startup |
| Micronaut | Modern | Apache-2.0 | Low memory, AOT |
| Helidon | Modern | Apache-2.0 | Oracle, cloud-native |
| Javalin | Modern | Apache-2.0 | Lightweight, Kotlin-friendly |

### Kotlin

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Ktor** | Modern | Apache-2.0 | JetBrains, Kotlin-native |
| Spring Boot | Standard | Apache-2.0 | Good Kotlin support |
| http4k | Modern | Apache-2.0 | Functional, testable |

**Recommendation:**
- Enterprise Java → **Spring Boot**
- Cloud-native → **Quarkus** or **Micronaut**
- Kotlin → **Ktor** or **Spring Boot**
- Lightweight → **Javalin**

## Native Image (GraalVM)

| Framework | Native Support |
|-----------|----------------|
| Quarkus | Excellent |
| Micronaut | Excellent |
| Spring Boot 3 | Good (with hints) |
| picocli | Excellent |

## Logging

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **SLF4J** | Standard | MIT | Facade |
| **Logback** | Standard | EPL-1.0/LGPL-2.1 | SLF4J implementation |
| Log4j2 | Modern | Apache-2.0 | High performance |
| kotlin-logging | Modern | Apache-2.0 | Kotlin wrapper |

**Recommendation:** **SLF4J + Logback** (or **Log4j2** for high throughput)

## Pre-commit & Hooks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **pre-commit** | Standard | MIT | Python-based |
| Gradle tasks | - | - | git-hooks plugin |
| lefthook | Modern | MIT | Fast (Go) |

**Recommendation:** **pre-commit** or Gradle **git-hooks** plugin

## Project Structure

**Gradle (Kotlin DSL):**
```
project/
├── build.gradle.kts
├── settings.gradle.kts
├── gradle/
│   ├── libs.versions.toml    # Version catalog
│   └── wrapper/
├── src/
│   ├── main/
│   │   ├── java/ or kotlin/
│   │   └── resources/
│   └── test/
│       ├── java/ or kotlin/
│       └── resources/
└── gradlew
```

**Multi-module:**
```
project/
├── settings.gradle.kts
├── gradle/libs.versions.toml
├── app/
│   └── build.gradle.kts
├── core/
│   └── build.gradle.kts
└── api/
    └── build.gradle.kts
```

## Version Catalog Example

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "1.9.22"
spring-boot = "3.2.1"
junit = "5.10.1"

[libraries]
spring-boot-starter = { module = "org.springframework.boot:spring-boot-starter", version.ref = "spring-boot" }
junit-jupiter = { module = "org.junit.jupiter:junit-jupiter", version.ref = "junit" }

[plugins]
kotlin-jvm = { id = "org.jetbrains.kotlin.jvm", version.ref = "kotlin" }
spring-boot = { id = "org.springframework.boot", version.ref = "spring-boot" }
```

## build.gradle.kts Example

```kotlin
plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.spring.boot)
    id("com.diffplug.spotless") version "6.23.3"
}

dependencies {
    implementation(libs.spring.boot.starter)
    testImplementation(libs.junit.jupiter)
}

spotless {
    kotlin {
        ktfmt()
    }
    java {
        googleJavaFormat()
    }
}
```
