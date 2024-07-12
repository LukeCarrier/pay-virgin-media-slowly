*** Settings ***
Documentation  Pay Virgin Media a penny at a time

Library  RPA.Browser.Playwright
Library  RPA.HTTP
Library  String


*** Tasks ***
Pay the bill
    Log in to My Virgin Media
    ${balance} =  Open payment page and check balance
    WHILE  $balance != "£0.00"
        TRY
            Navigate to quick payment form
            Fill and submit the quick pay form
            Fill and submit the security code form
        EXCEPT
            Log  Retrying payment since Virgin fucked something up
        FINALLY
            ${balance} =  Open payment page and check balance
        END
    END
    Stop the world


*** Keywords ***
Log in to My Virgin Media
    New Browser  headless=False  browser=firefox

    Set Browser Timeout  timeout=30s
    New Page             https://www.virginmedia.com/myvmo2

    # Use cookiebro to extract these, and cookies.jq to format them
    # FIXME

    TRY
        ${acceptCookies} =  Get Element  //button[contains(text(), "Accept essential cookies only")]
        Click  ${acceptCookies}
    EXCEPT
        Log  No cookie prompt this time
    END

    Click                  //span[contains(text(), "Sign in")]
    Wait For All Promises

Open payment page and check balance
    Go To  https://www.virginmedia.com/support/help/billing-and-payment/my-virgin-media/billing
    TRY
        Get Element  //div[contains(concat(' ', @class, ' '), ' tour-tooltip ')]
        Click        //button[contains(concat(' ', @class, ' '), ' tour-tooltip-header__close ')]
    EXCEPT
        Log  No tour this time around
    END

    Hover  //button[contains(text(), "Make a payment")]
    Click  //button[contains(text(), "Make a payment")]

    ${balance} =  Get Text  //p[contains(concat(' ', @class, ' '), ' bill-payment-card-price ')]
    RETURN  ${balance}

Navigate to quick payment form
    Click  //button[contains(text(), "Pay now")]

Fill and submit the quick pay form
    Fill Text          //input[@name="amount"]                0.01
    Hover              //input[contains(@value, "Continue")]
    Fill Text          //input[@name="emailAddress"]          luke@carrier.family
    Scroll To          vertical=100%
    Fill Text          //input[@name="confirmEmailAddress"]   luke@carrier.family
    Click              //input[contains(@value, "Continue")]

Fill and submit the security code form
    Type Text  //iframe[@id="myiframe"] >>> //iframe[@id="#securityCode"] >>> //input[@id="securityCode"]  333
    Click      //iframe[@id="myiframe"] >>> //input[contains(@value, "Continue")]
    Hover      //input[contains(@value, "Pay now")]
    Click      //input[contains(@value, "Pay now")]

Stop the world
    Close Browser
