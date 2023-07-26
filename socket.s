.data

sockaddr:
  .short 2                // AF_INET
  .short 0x77ac               // (Port) 44151
  .long 0x916d4e34 //0x344e6d91        // (IP)   52.78.109.145(0x344e6d91) , 0x100007f
  // with sin_zero(8byte)

.text

.global _start

// x8 : syscall number
// x0 -> x1 -> x2
// x0 : ret value

_start:
    // socket(x0, x1, x2)
    mov x0, #2 // AF_INET
    mov x1, #1 // SOCK_STREAM
    mov x2, #6 // IPPROTO_TCP
    mov x8, #198 // socket
    svc #0


    //                  x0                          x1
    //int connect(int sockfd, const struct sockaddr *addr,
    //                          x2
    //               socklen_t addrlen);
    adr x1, sockaddr
    // save the socket fd
    str x0, [x1, #8]

    mov x2, #16
    mov x8, #203 // connect
    svc 0

_recvfrom:
    //                      x0          x1          x2          x3
    // ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,
    //                                      x4              x5
    //                    struct sockaddr *src_addr, socklen_t *addrlen);
    adr x1, sockaddr
    ldr x0, [x1, #8] // sockfd
    add x1, x1, #16 // buf
    add x1, x1, x19
    mov x2, #8 // len
    mov x3, #0
    //mov x4, #0
    //mov x5, #0
    mov x8, #207
    svc #0
    cmp x0, #1 //1, 7 | 8
    add x19, x19, #1
    beq _recvfrom

    // x19 <- 결과값으로 쓰자
    // x20 <- 임시값

    // buf[0] + buf[2] + buf[4]
    adr x1, sockaddr
    add x1, x1, #16 // buf
    ldrb w19, [x1, #0]
    mov	w20, w19
    ldrb w19, [x1, #2]
    add	w20, w20, w19
    ldrb w19, [x1, #4]
    add	w20, w20, w19
    ldrb w19, [x1, #6]
    add	w20, w20, w19
    
    sub w20, w20, #192 // 합으로 만듦

    mov w13, #10          // Move 10 to the w13 register
    udiv w14, w20, w13      // Divide sum by 10
    msub w15, w14, w13, w20 // remainder
    add w14, w14, #48 // + '0'

    strb w14, [x1]        // Store the tens digit ASCII code at buf[0]

    //add w20, w20, w15 // add remainder
    add w15, w15, #48     // Add '0' ASCII code to get the ones digit ASCII code

    strb w15, [x1, 1]     // Store the ones digit ASCII code at buf[1]

    mov w14, #0x0a        // Place 0x0a (newline character) into w4 register
    strb w14, [x1, 2]     // Store the newline character at buf[2]


    //sub x6, x6, #1 // 반복 횟수 감소
    //cbnz x6, .loop_start // x6이 0이 아닐 경우 루프 시작으로 이동
 

    //                      x0              x1            x2        x3
    // ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
    //                                          x4                  x5
    //                  const struct sockaddr *dest_addr, socklen_t addrlen);
    adr x1, sockaddr
    ldr x0, [x1, #8] // sockfd
    mov x2, #3 // len
    add x1, x1, #16
    mov x8, #206
    svc #0

//.loop2_start:
    //                         x0          x1         x2        x3
    // ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,
    //                                         x4               x5
    //                    struct sockaddr *src_addr, socklen_t *addrlen);
    adr x1, sockaddr
    ldr x0, [x1, #8] // sockfd
    add x1, x1, #12 // buf <- 여기서 sockfd 지워진다!
    mov x2, #4
    // x4 = 0
    // x5 = 0
    mov x8, #207 // recvfrom
    svc #0

    mov x0, #1
    mov x2, #4
    mov x8, #64
    svc 0

// x8 : 93
// x1 : status
// void exit(int status);
    mov x8, #0x5d // exit
    mov x0, #0
    svc #0

