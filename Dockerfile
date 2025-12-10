# ============================
# 1단계: 빌드 (build stage)
# ============================
FROM gradle:jdk21-jammy AS build
WORKDIR /home/gradle/project

# 👇 1) 의존성 관련 파일만 먼저 복사
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
# gradle.properties 있으면 이것도
# COPY gradle.properties ./

# 👇 2) 의존성만 먼저 받기 (캐시용)
RUN gradle dependencies --no-daemon || true

# 👇 3) 그 다음에 나머지 소스 전체 복사
COPY --chown=gradle:gradle . .

# 👇 4) 실제 bootJar 빌드 (테스트는 배포용이므로 생략 권장)
RUN gradle clean bootJar -x test --no-daemon


# ============================
# 2단계: 실행 (run stage)
# ============================
FROM eclipse-temurin:21-jdk-jammy

# 타임존 설정 (Asia/Seoul)
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

# 빌드 단계에서 만든 JAR 복사 (이름 통일)
COPY --from=build /home/gradle/project/build/libs/*.jar app.jar

# Render에서 내려주는 PORT 사용 (로컬 기본값 8080)
ENV PORT=8080
EXPOSE 8080

# Spring Boot 실행
ENTRYPOINT ["java", "-Duser.timezone=Asia/Seoul", "-jar", "app.jar"]