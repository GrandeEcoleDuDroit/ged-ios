import Testing
@testable import GrandeEcoleDuDroit

struct VerifyEmailFormatUseCaseTests {

    @Test
    func should_return_true_when_email_format_is_correct() {
        let email = "user@example.com" // simulate userFixture.email

        let result = VerifyEmailFormatUseCase.execute(email)

        #expect(result == true)
    }

    @Test
    func should_return_false_when_email_does_not_contain_at_symbol() {
        let result = VerifyEmailFormatUseCase.execute("email.com")

        #expect(result == false)
    }

    @Test
    func should_return_false_when_email_does_not_contain_dot_after_at() {
        let result = VerifyEmailFormatUseCase.execute("email@com")

        #expect(result == false)
    }

    @Test
    func should_return_false_when_email_does_not_contain_string_after_last_dot() {
        let result = VerifyEmailFormatUseCase.execute("email@com.")

        #expect(result == false)
    }
}
