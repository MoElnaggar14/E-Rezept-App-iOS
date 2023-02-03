//
//  Copyright (c) 2023 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

@testable import AVS
import DataKit
import Foundation
import Nimble
import OpenSSL
import XCTest

// swiftlint:disable line_length
final class AuthEnvelopedWithUnauthAttributesTests: XCTestCase {
    let x509rsa = try! X509(pem: x509rsaPem.data(using: .utf8)!)

    func testConvertMessage() throws {
        // given
        let message = AVSMessage.Fixtures.completeExample
        let recipients = [x509rsa]
        let mockAvsCmsEncrypter = MockAVSCmsEncrypter()
        mockAvsCmsEncrypter.cmsEncryptRecipientsReturnValue =
            try! Data(
                hex: "3082024C060B2A864886F70D0109100117A082023B30820237020100318201EE308201EA0201003081A630819A310B3009060355040613024445311F301D060355040A0C1667656D6174696B20476D6248204E4F542D56414C494431483046060355040B0C3F496E737469747574696F6E2064657320476573756E646865697473776573656E732D4341206465722054656C656D6174696B696E667261737472756B7475723120301E06035504030C1747454D2E534D43422D4341323420544553542D4F4E4C5902070172DEC14257C6303806092A864886F70D010107302BA00D300B0609608648016503040201A11A301806092A864886F70D010108300B06096086480165030402010482010009294359DC23728EEDF67E1FC3036027657B81D99E540DECDBA43E439CA0B823A6FA74ACD17613FBDFFBFDF188433CA89FCA385579C8E8581D8D9861F8119A6BFECC6A81FE3F1C1073EE29F96D489F335D82DBE471616C8B213F8BE8887A32611314A827C1E6E74DFEFCA7BD5F3E874E9D4CA419CECFB4097AEDC292630FE1A2EC31E2BF8C6BC06702431567722D0302B2A56B3C3D43A8109B07127F5255D603A6219B87D718A262F7FF021B881C5328B4EF5B5BD1C9C9F3C29B681ECE275A205609DA58914EB90583A959662A6E03827F6F5F12A7469304F51C75DE5AD6E76CB757CFAFB1F5F639C33A31CF79AAB8E183BA5C3C70609B91B4605359795DD2C5302E06092A864886F70D010701301E060960864801650304012E3011040C96786EFD14E5B14BD42156470201108001920410568B39AF53EE840952F46CE5FBCEBEB0"
            )
        let sut = AuthEnvelopedWithUnauthAttributes(
            avsCmsEncrypter: mockAvsCmsEncrypter
        )

        // when
        let result = try sut.convert(message, recipients: recipients)

        // then
        expect(mockAvsCmsEncrypter.cmsEncryptRecipientsCalled) == true
        expect(mockAvsCmsEncrypter.cmsEncryptRecipientsCallsCount) == 1
        expect(result.hexString()) ==
            "3082032E060B2A864886F70D0109100117A082031D30820319020100318201EE308201EA0201003081A630819A310B3009060355040613024445311F301D060355040A0C1667656D6174696B20476D6248204E4F542D56414C494431483046060355040B0C3F496E737469747574696F6E2064657320476573756E646865697473776573656E732D4341206465722054656C656D6174696B696E667261737472756B7475723120301E06035504030C1747454D2E534D43422D4341323420544553542D4F4E4C5902070172DEC14257C6303806092A864886F70D010107302BA00D300B0609608648016503040201A11A301806092A864886F70D010108300B06096086480165030402010482010009294359DC23728EEDF67E1FC3036027657B81D99E540DECDBA43E439CA0B823A6FA74ACD17613FBDFFBFDF188433CA89FCA385579C8E8581D8D9861F8119A6BFECC6A81FE3F1C1073EE29F96D489F335D82DBE471616C8B213F8BE8887A32611314A827C1E6E74DFEFCA7BD5F3E874E9D4CA419CECFB4097AEDC292630FE1A2EC31E2BF8C6BC06702431567722D0302B2A56B3C3D43A8109B07127F5255D603A6219B87D718A262F7FF021B881C5328B4EF5B5BD1C9C9F3C29B681ECE275A205609DA58914EB90583A959662A6E03827F6F5F12A7469304F51C75DE5AD6E76CB757CFAFB1F5F639C33A31CF79AAB8E183BA5C3C70609B91B4605359795DD2C5302E06092A864886F70D010701301E060960864801650304012E3011040C96786EFD14E5B14BD42156470201108001920410568B39AF53EE840952F46CE5FBCEBEB0A281DF3081DC06082A8214004C04812D3181CF3081CC1621332D534D432D422D546573746B617274652D3838333131303030303131363837333081A630819A310B3009060355040613024445311F301D060355040A0C1667656D6174696B20476D6248204E4F542D56414C494431483046060355040B0C3F496E737469747574696F6E2064657320476573756E646865697473776573656E732D4341206465722054656C656D6174696B696E667261737472756B7475723120301E06035504030C1747454D2E534D43422D4341323420544553542D4F4E4C5902070172DEC14257C6"
    }

    func testRecipientEmailsAttribute() throws {
        let recipients = [x509rsa]

        let result = try AuthEnvelopedWithUnauthAttributes.recipientEmailsUnAuthAttribute(recipients: recipients)
        expect(result.hexString()) ==
            "3081DC06082A8214004C04812D3181CF3081CC1621332D534D432D422D546573746B617274652D3838333131303030303131363837333081A630819A310B3009060355040613024445311F301D060355040A0C1667656D6174696B20476D6248204E4F542D56414C494431483046060355040B0C3F496E737469747574696F6E2064657320476573756E646865697473776573656E732D4341206465722054656C656D6174696B696E667261737472756B7475723120301E06035504030C1747454D2E534D43422D4341323420544553542D4F4E4C5902070172DEC14257C6"
    }

    func testRecipientEmail() throws {
        let result = try AuthEnvelopedWithUnauthAttributes.recipientEmail(x509rsa)
        expect(result?.hexString()) ==
            "3081CC1621332D534D432D422D546573746B617274652D3838333131303030303131363837333081A630819A310B3009060355040613024445311F301D060355040A0C1667656D6174696B20476D6248204E4F542D56414C494431483046060355040B0C3F496E737469747574696F6E2064657320476573756E646865697473776573656E732D4341206465722054656C656D6174696B696E667261737472756B7475723120301E06035504030C1747454D2E534D43422D4341323420544553542D4F4E4C5902070172DEC14257C6"
    }

    func testExtractTeleTrustAdmissionRegistrationNumber() throws {
        let result = try x509rsa.extractTeleTrustAdmissionRegistrationNumber()
        expect(result?.utf8string) == "3-SMC-B-Testkarte-883110000116873"
    }

    static let x509rsaPem =
        """
        -----BEGIN CERTIFICATE-----
        MIIFSTCCBDGgAwIBAgIHAXLewUJXxjANBgkqhkiG9w0BAQsFADCBmjELMAkGA1UE
        BhMCREUxHzAdBgNVBAoMFmdlbWF0aWsgR21iSCBOT1QtVkFMSUQxSDBGBgNVBAsM
        P0luc3RpdHV0aW9uIGRlcyBHZXN1bmRoZWl0c3dlc2Vucy1DQSBkZXIgVGVsZW1h
        dGlraW5mcmFzdHJ1a3R1cjEgMB4GA1UEAwwXR0VNLlNNQ0ItQ0EyNCBURVNULU9O
        TFkwHhcNMjAwMTI0MDAwMDAwWhcNMjQxMjExMjM1OTU5WjCB5TELMAkGA1UEBhMC
        REUxEDAOBgNVBAcMB0hhbWJ1cmcxDjAMBgNVBBEMBTIyNDUzMRgwFgYDVQQJDA9I
        ZXNlbHN0w7xja2VuIDkxKjAoBgNVBAoMITMtU01DLUItVGVzdGthcnRlLTg4MzEx
        MDAwMDExNjg3MzEdMBsGA1UEBRMUODAyNzY4ODMxMTAwMDAxMTY4NzMxEjAQBgNV
        BAQMCVNjaHJhw59lcjESMBAGA1UEKgwJU2llZ2ZyaWVkMScwJQYDVQQDDB5BcG90
        aGVrZSBhbSBGbHVnaGFmZW5URVNULU9OTFkwggEiMA0GCSqGSIb3DQEBAQUAA4IB
        DwAwggEKAoIBAQCZ9ihWMq2T1C9OEoXpbWJWjALF/X6pbRmzmln2gdRxW7k/BS59
        YpONamWX3Wmjc7ELpmiU+5atOpSrFhS7QCQomTyCbnuIYOB6WVaYgDREceZ7bu29
        QxD04aHGGrOwaU/55i4f3JTa88QtyMOqPEA/YW3XoCKdPwouiVEP8AXJ+8dRiYCS
        SzPUKOOy+R53sMhrTmpkwGNfOmq9Kg1uX8NRDg0Lamv41O9XbsfJTuzVa4EcKALx
        HEMprsUokV9WaGVK0nHCyU0TTi6V9EqslVoK1iyMgUUl2nfx1/aRtUViFbXtd6DR
        6SeUhcqIzFOVBnl9EY4alAnHfR/qE8iBe6bbAgMBAAGjggFFMIIBQTAdBgNVHQ4E
        FgQUGRLcBNLvAKTcCYYIS+HLzaac0EAwDAYDVR0TAQH/BAIwADA4BggrBgEFBQcB
        AQQsMCowKAYIKwYBBQUHMAGGHGh0dHA6Ly9laGNhLmdlbWF0aWsuZGUvb2NzcC8w
        DgYDVR0PAQH/BAQDAgQwMB8GA1UdIwQYMBaAFHrp4W/qFFkWBe4D6dP9Iave6dme
        MCAGA1UdIAQZMBcwCgYIKoIUAEwEgSMwCQYHKoIUAEwETDCBhAYFKyQIAwMEezB5
        pCgwJjELMAkGA1UEBhMCREUxFzAVBgNVBAoMDmdlbWF0aWsgQmVybGluME0wSzBJ
        MEcwFwwVw5ZmZmVudGxpY2hlIEFwb3RoZWtlMAkGByqCFABMBDYTITMtU01DLUIt
        VGVzdGthcnRlLTg4MzExMDAwMDExNjg3MzANBgkqhkiG9w0BAQsFAAOCAQEALmkJ
        S6sCvx0cyDcFMRFiCJ7Po3H6jAPGgVmuQsldo+AHcjN7YAuM/7JwOBulvycZOEBi
        Mf+NYkjfzQRM16h9SHspjFsr8yD78u0JfdKJEYWnpTUEDTl0C0ssv++obWLyw/lj
        1623pjn5Kb0x5yjEbzSGo3kk5S050Bnwf39JGVzv2M1j31y9CQQSAxT3EKl937Gj
        306acGmt6vjDDd0GB8P6nPreulTYh1M0Tlli53gfP7o987q2Pq/jIK13ExF6t5WN
        PCqpN2JbFY8waA6PzoT57zKdT6sB/w26rA2Gnc9eGp9pZ9DH11Qw+x+SArCs1eEh
        0jqYhPIqIs2gJPl3hw==
        -----END CERTIFICATE-----
        """
}
