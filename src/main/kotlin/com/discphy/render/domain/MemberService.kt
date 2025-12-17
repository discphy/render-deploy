package com.discphy.render.domain

import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class MemberService(
    private val memberRepository: MemberRepository
) {
    fun findAll(): List<Member> = memberRepository.findAll()

    fun findById(id: Long): Member? = memberRepository.findByIdOrNull(id)

    @Transactional
    fun create(name: String, email: String): Member {
        return memberRepository.save(Member(name = name, email = email))
    }

    @Transactional
    fun update(id: Long, name: String, email: String): Member? {
        val member = memberRepository.findByIdOrNull(id) ?: return null
        member.name = name
        member.email = email
        return member
    }

    @Transactional
    fun delete(id: Long): Boolean {
        val member = memberRepository.findByIdOrNull(id) ?: return false
        memberRepository.delete(member)
        return true
    }
}