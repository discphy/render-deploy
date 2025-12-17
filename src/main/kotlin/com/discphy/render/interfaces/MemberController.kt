package com.discphy.render.interfaces

import com.discphy.render.domain.Member
import com.discphy.render.domain.MemberService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/members")
class MemberController(
    private val memberService: MemberService
) {
    @GetMapping
    fun findAll(): List<MemberResponse> {
        return memberService.findAll().map { it.toResponse() }
    }

    @GetMapping("/{id}")
    fun findById(@PathVariable id: Long): ResponseEntity<MemberResponse> {
        val member = memberService.findById(id) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(member.toResponse())
    }

    @PostMapping
    fun create(@RequestBody request: MemberRequest): ResponseEntity<MemberResponse> {
        val member = memberService.create(request.name, request.email)
        return ResponseEntity.status(HttpStatus.CREATED).body(member.toResponse())
    }

    @PutMapping("/{id}")
    fun update(@PathVariable id: Long, @RequestBody request: MemberRequest): ResponseEntity<MemberResponse> {
        val member = memberService.update(id, request.name, request.email) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(member.toResponse())
    }

    @DeleteMapping("/{id}")
    fun delete(@PathVariable id: Long): ResponseEntity<Void> {
        return if (memberService.delete(id)) {
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }
    }
}

data class MemberRequest(
    val name: String,
    val email: String
)

data class MemberResponse(
    val id: Long,
    val name: String,
    val email: String
)

fun Member.toResponse() = MemberResponse(
    id = id!!,
    name = name,
    email = email
)