.file "main.S"
#include <avr/io.h>

.EQU speed, 100

.text
.global setup
.global loop
setup:
    RCALL setupPins
    RCALL setupUSART
    RCALL setupPWM
    RCALL setupADC
    RET

loop:
    RCALL serialReceive
    RJMP loop

setupPins:
    ; Set DP 3 as an Output
    LDI r16, 0b00001000
    STS DDRD, r16
    ; Set DP 8, 9, 10, 11 as Outputs
    LDI r16, 0b00001111
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
    ; Timer 1 (right motor):
    ; pin 9     ->  OC1A
    ; pin 10    ->  OC1B

    ; Timer 2 (left motor)
    ; pin 11    ->  OC2A
    ; pin 3     ->  OC2B

    ; Timer 1:
    ; set PWM mode to fast PWM with 8 bits
    LDI r16, (1 << COM1A1) | (1 << COM1B1) | (1 << WGM10)
    STS TCCR1A, r16
    ; set pre-scaler to 64
    LDI r16, (1 << CS11) | (1 << CS10)
    STS TCCR1B, r16

    ; Timer 2:
    ; set PWM mode to fast PWM
    LDI r16, (1 << COM2A1) | (1 << COM2B1) | (1 << WGM20)
    STS TCCR2A, r16
    ; set pre-scaler to 64
    LDI r16, (1 << CS22)
    STS TCCR2B, r16
    RET

setupADC:
    ; set and start the ADC conversion on pin 0 port c
    LDI r16, 0b01000000
    STS ADMUX, r16
    ; set pre-scaler to 128 and mode to auto-triggering
    LDI r16, 0b11100111
    STS ADCSRA, r16
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
    LDI r16, 0
    LDS r17, ADCL
    LDS r18, ADCH

    STS OCR1A, r17
    STS OCR2A, r16
    STS OCR1B, r16
    STS OCR2B, r17
    RET

moveRight:
    LDI r16, 0
    LDS r17, ADCL
    LDS r18, ADCH

    STS OCR1A, r16
    STS OCR2A, r17
    STS OCR1B, r17
    STS OCR2B, r16
    RET

moveForward:
    LDS r16, ADCL
    LDS r18, ADCH
    LDI r17, 0

    STS OCR1A, r16
    STS OCR2A, r16
    STS OCR1B, r17
    STS OCR2B, r17
    RET

moveBackward:
    LDI r16, 0
    LDS r17, ADCL
    LDS r18, ADCH

    STS OCR1A, r16
    STS OCR2A, r16
    STS OCR1B, r17
    STS OCR2B, r17
    RET

shoot:
    ; fire the bomb :p
    SBI PORTB - 0x20, 0
    RCALL delay
    CBI PORTB - 0x20, 0
    RET

stop:
    ; stop the robot movement
    LDI r16, 0

    STS OCR1A, r16
    STS OCR1B, r16
    STS OCR2A, r16
    STS OCR2B, r16
    RET

delay:
    ; custom delay for 1 second
    ldi  r18, 82
    ldi  r19, 43
    ldi  r20, 100
temp:
    dec  r20
    brne temp
    dec  r19
    brne temp
    dec  r18
    brne temp
    nop
    RET
