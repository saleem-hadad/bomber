.file "main.S"
#include <avr/io.h>
.text
.global setup
.global loop

setup:
    RCALL setupPins
    RCALL setupUSART

loop:
    RCALL serialReceive
    RJMP loop

setupPins:
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

serialReceive:
    LDS r17, UCSR0A
    SBRS r17, RXC0
    RJMP serialReceive
    ; Get and return received data from buffer
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
    RET
