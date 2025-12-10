package com.discphy.render

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class RenderDeployApplication

fun main(args: Array<String>) {
    runApplication<RenderDeployApplication>(*args)
}
