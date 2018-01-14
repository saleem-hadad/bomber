.file "main.S"
#include <avr/io.h>
.text
.global setup
.global loop

setup:
    RCALL setupPins
    RCALL setupUSART
    RCALL setupPWM

loop:
    RCALL serialReceive
    RJMP loop

setupPins:
    ; Set DP 3 as an Output
    LDI r16, 0b00001000
    STS DDRD, r16
    ; Set DP 9, 10, 11 as Outputs
    LDI r16, 0b00001110
    STS DDRB, r16
    RET

setupUSART:
    ; set the baud rate to 115200
    LDI r16, 0x08
    LDI r17, 0x00
    STS UBRR0L, r16
    STS UBRR0H, r17

    ; set frame, 8 bits, 2 stop bit
    LDI r16, 0b00001110
    STS UCSR0C, r16

    ; enable the rec. of the serial
    LDI r16, (1 << RXEN0) | (1 << TXEN0)
    STS UCSR0B, r16
    RET

setupPWM:
    ; Timer 1 (pins 9, 10) [right motor]
    ; set PWM mode to fast PWM with 8 bits
    LDI r16, (1 << COM1A1) | (1 << COM1B1) | (1 << WGM10)
    STS TCCR1A, r16
    ; set pre-scaler to 64
    LDI r16, (1 << CS11) | (1 << CS10)
    STS TCCR1B, r16

    ; Timer 2 (pins 3, 11) [left motor]
    ; set PWM mode to fast PWM
    LDI r16, (1 << COM2A1) | (1 << COM2B1) | (1 << WGM20)
    STS TCCR2A, r16
    ; set pre-scaler to 64
    LDI r16, (1 << CS22)
    STS TCCR2B, r16
    RET

serialReceive:
    LDS r17, UCSR0A
    SBRS r17, RXC0
    RJMP serialReceive
    ; get the ready data from buffer
    LDS r16, UDR0

    ; check if the action is left
    LDI r17, 75
    CP r16, r17
    BREQ moveLeft

    ; check if the action is right
    LDI r17, 80
    CP r16, r17
    BREQ moveRight

    ; check if the action is forward
    LDI r17, 85
    CP r16, r17
    BREQ moveForward

    ; check if the action is backward
    LDI r17, 90
    CP r16, r17
    BREQ moveBackward

    ; check if the action is shoot
    LDI r17, 95
    CP r16, r17
    BREQ shoot

    ; check if the action is stop
    LDI r17, 100
    CP r16, r17
    BREQ stop
    RET

moveLeft:
    RET

moveRight:
    RET

moveForward:
    RET

moveBackward:
    RET

shoot:
    RET

stop:
    LDI r16, 0
    STS OCR1A, r16
    STS OCR1B, r16
    STS OCR2A, r16
    STS OCR2B, r16
    RET
