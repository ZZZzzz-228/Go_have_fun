package com.gohavefun.app.data

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.random.Random

data class ChatState(
    val chatId: String = "",
    val myUserId: String = "me",
    val partnerName: String = "Аня",
    val secondsRemaining: Int = AppConstants.CHAT_DURATION_SECONDS,
    val totalSeconds: Int = AppConstants.CHAT_DURATION_SECONDS,
    val messages: List<ChatMessage> = emptyList(),
    val myWantsExtend: Boolean = false,
    val partnerWantsExtend: Boolean = false,
    val icebreaker: String? = null,
    val isExpired: Boolean = false,
)

/**
 * Логика чата. Перенесено из Flutter (ChatNotifier).
 * Чат "горит" 15 минут, есть ледоколы, продление +5 мин и эмуляция ответов партнёра.
 */
class ChatViewModel : ViewModel() {

    private val _state = MutableStateFlow(ChatState())
    val state: StateFlow<ChatState> = _state.asStateFlow()

    private var timerJob: Job? = null
    private var started = false

    fun initChat(chatId: String) {
        if (started) return
        started = true
        val icebreaker = AppConstants.icebreakerTemplates.random()
        _state.value = _state.value.copy(
            chatId = chatId,
            icebreaker = icebreaker,
            secondsRemaining = AppConstants.CHAT_DURATION_SECONDS,
        )
        startTimer()
    }

    private fun startTimer() {
        timerJob?.cancel()
        timerJob = viewModelScope.launch {
            while (_state.value.secondsRemaining > 0) {
                delay(1000)
                val remaining = _state.value.secondsRemaining - 1
                if (remaining <= 0) {
                    _state.value = _state.value.copy(secondsRemaining = 0, isExpired = true)
                    break
                } else {
                    _state.value = _state.value.copy(secondsRemaining = remaining)
                }
            }
        }
    }

    fun sendMessage(text: String) {
        if (_state.value.isExpired || text.isBlank()) return
        val msg = ChatMessage(
            id = System.currentTimeMillis().toString(),
            senderId = "me",
            text = text,
            sentAtMillis = System.currentTimeMillis(),
        )
        _state.value = _state.value.copy(messages = _state.value.messages + msg)

        // Эмуляция ответа партнёра
        viewModelScope.launch {
            delay((1 + Random.nextInt(3)) * 1000L)
            if (_state.value.isExpired) return@launch
            val replies = listOf(
                "Хаха, интересно 😄",
                "О, серьёзно?",
                "Мне тоже нравится!",
                "Давай встретимся в кофейне!",
                "Окей, иду 👋",
                "Где именно ты находишься?",
                "🔥",
            )
            val reply = ChatMessage(
                id = System.currentTimeMillis().toString() + "_p",
                senderId = "partner",
                text = replies.random(),
                sentAtMillis = System.currentTimeMillis(),
            )
            _state.value = _state.value.copy(messages = _state.value.messages + reply)
        }
    }

    fun requestExtend() {
        _state.value = _state.value.copy(myWantsExtend = true)
        viewModelScope.launch {
            delay(2000)
            val agrees = Random.nextBoolean()
            if (agrees) {
                _state.value = _state.value.copy(
                    secondsRemaining = _state.value.secondsRemaining + AppConstants.CHAT_EXTENSION_SECONDS,
                    totalSeconds = _state.value.totalSeconds + AppConstants.CHAT_EXTENSION_SECONDS,
                    myWantsExtend = false,
                    partnerWantsExtend = false,
                )
                startTimer()
            } else {
                _state.value = _state.value.copy(partnerWantsExtend = false)
            }
        }
    }
}
