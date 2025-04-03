//
//  main.swift
//  jerry-web-server
//
//  Created by Siarhei Blashuk on 02/04/2025.
//

import NIOCore
import NIOPosix

private final class EchoHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        print("channelRead: ", data)
        context.write(data, promise: nil)
    }

    // Flush it out. This can make use of gathering writes if multiple buffers are pending
    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        context.close(promise: nil)
    }
}

let arguments = CommandLine.arguments
let arg1 = arguments.dropFirst().first
let arg2 = arguments.dropFirst(2).first

let defaultHost = "::1"
let defaultPort = 8080

let port: Int
let host: String

switch (arg1, arg1.flatMap(Int.init), arg2.flatMap(Int.init)) {
case (.some(let h), _, .some(let p)):
    port = p
    host = h
case (.some(let h), .none, _):
    port = defaultPort
    host = h
case (_, .some(let p), .none):
    port = p
    host = defaultHost
default:
    port = defaultPort
    host = defaultHost
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let bootstrap = ServerBootstrap(group: group)
    // Specify backlog and enable SO_REUSEADDR for the server itself
    .serverChannelOption(.backlog, value: 256)
    .serverChannelOption(.socketOption(.so_reuseaddr), value: 1)
    // Set the handlers that are appled to the accepted Channels
    .childChannelInitializer { channel in
        // Ensure we don't read faster than we can write by adding the BackPressureHandler into the pipeline.
        channel.eventLoop.makeCompletedFuture {
            try channel.pipeline.syncOperations.addHandler(BackPressureHandler())
            try channel.pipeline.syncOperations.addHandler(EchoHandler())
        }
    }
    // Enable SO_REUSEADDR for the accepted Channels
    .childChannelOption(.socketOption(.so_reuseaddr), value: 1)
    .childChannelOption(.maxMessagesPerRead, value: 16)
    .childChannelOption(.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
defer {
    try! group.syncShutdownGracefully()
}

let channel = try { () -> Channel in
    return try bootstrap.bind(host: host, port: port).wait()
}()

print("Server started and listening on \(channel.localAddress!)")

try channel.closeFuture.wait()

print("Server closed")
