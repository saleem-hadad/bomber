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
    ; set ddrb pin 4 output
    SBI 0x23 - 0x20, 4
    RET

setupUSART:
    ; set the baud rate to 115200
    LDI r16, 0x08
    LDI r17, 0x00
    STS UBRR0L, r16
    STS UBRR0H, r17

    ; set frame, 8 bits, 2 stop bit
    LDI	r16, 0b00001110
	STS	UCSR0C, r16

    ; enable the rec. of the serial
    LDI	r16, (1 << RXEN0) | (1 << TXEN0)
	STS	UCSR0B, r16
    RET

serialReceive:
    LDS r17, UCSR0A
    SBRS r17, RXC0
    RJMP serialReceive
    ; Get and return received data from buffer
    LDS r16, UDR0

    ; check if the action is right
    LDI r17, 80
    CP r16, r17
    BREQ ledOn
    ; check if the action is left
    ; check if the action is forward
    ; check if the action is backward
    
    LDI r17, 100
    CP r16, r17
    BREQ ledOff
        
    RET

ledOn:
    ; turn on the led
    SBI 0x24 - 0x20, 4
    RET

ledOff:
    ; turn off the led
    CBI 0x24 - 0x20, 4
    RET
