import Testing
@testable import ARCNetworking

struct ARCNetworkingTests {
    @Test
    func testHelloFunction() {
        #expect(ARCNetworking.hello() == "Hello from ARCNetworking!")
    }
}
