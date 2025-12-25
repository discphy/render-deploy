# ============================
# 1단계: 빌드 (build stage)
# ============================
FROM gradle:jdk21-jammy AS build
WORKDIR /home/gradle/project

# Gradle Kotlin DSL 파일들 먼저 복사
COPY build.gradle.kts settings.gradle.kts ./

# 버전 카탈로그 쓰면 (있으면) 추가
# COPY gradle/libs.versions.toml gradle/libs.versions.toml

# Gradle Wrapper 디렉터리
COPY gradle ./gradle

# 의존성만 먼저 다운 (캐시용)
RUN gradle dependencies --no-daemon || true

# 나머지 소스 전체 복사
COPY --chown=gradle:gradle . .

# 실제 bootJar 빌드 (배포용이니 테스트는 제외)
RUN gradle clean bootJar -x test --no-daemon


# ============================
# 2단계: 실행 (run stage)
# ============================
FROM eclipse-temurin:21-jdk-jammy

# 타임존 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

# 빌드 결과 JAR 복사 (이름 통일)
COPY --from=build /home/gradle/project/build/libs/*.jar app.jar

# Render에서 PORT 환경 변수 사용
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", \
  "-Duser.timezone=Asia/Seoul", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=70.0", \
  "-XX:+UseG1GC", \
  "-XX:+ExitOnOutOfMemoryError", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]