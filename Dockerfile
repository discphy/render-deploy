# 1단계: 빌드(Stage: build)
FROM gradle:jdk21-jammy AS build
WORKDIR /home/gradle/project

# 전체 소스 복사
COPY --chown=gradle:gradle . .

# Spring Boot JAR 빌드
RUN gradle clean bootJar --no-daemon


# 2단계: 실행(Stage: run)
FROM eclipse-temurin:21-jre

# 타임존 설정 (Asia/Seoul)
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

# build 단계에서 만든 JAR 복사 (버전에 상관없이 app.jar로 통일)
COPY --from=build /home/gradle/project/build/libs/*.jar app.jar

# Render에서 내려주는 PORT 사용 (로컬 기본값 8080)
ENV PORT=8080
EXPOSE 8080

# Spring Boot 실행 (타임존 옵션 포함)
ENTRYPOINT ["java", "-Duser.timezone=Asia/Seoul", "-jar", "app.jar"]