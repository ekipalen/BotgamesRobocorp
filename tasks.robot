*** Settings ***
Library    RPA.Browser.Selenium   auto_close=${FALSE}

*** Variables ***
${url}            https://developer.automationanywhere.com/challenges/financialvalidation-challenge.html
${rusty_user}     finance_dept@foodmartgrocerycorp.com
${rusty_pwd}    dR6Si6O&?u1rIp2iSOz-
${btn_login}    xpath://a[contains(text(),'Rusty Bank Login')]
${rusty_url}    https://developer.automationanywhere.com/challenges/financialvalidation-applogin.html
${ipt_user}     xpath://input[@id='inputEmail']
${ipt_pwd}      xpath://input[@id='inputPassword']
${ipt_remember_pwd}   xpath://input[@id='inputRememberPassword']
${btn_login2}   xpath://a[contains(text(),'Login')]
${btn_error}    xpath://button[contains(text(),'me to the Login Page')]
${submitCounter}     1
&{AccountLocators}   Checking (..2147)=//nav[@id='sidenavAccordion']/div[1]/div[1]/a[2]  
...     Checking (..2839)=//nav[@id='sidenavAccordion']/div[1]/div[1]/a[1]
...     Credit Card (..4513)=//nav[@id='sidenavAccordion']/div[1]/div[1]/a[4]
...     Savings (..3842)=//nav[@id='sidenavAccordion']/div[1]/div[1]/a[3]
${captha_accepted}   No

*** Keywords ***
Open Browser tabs and count Transactions
    Open Available Browser   ${url}   maximized=True
    ${transactionCount}    Get Element Count    css=input[id^='PaymentAmount']
    Click Element When Visible    ${btn_login}
    ${handles}=    Get Window Handles
    Set Global Variable    ${handles}
    
    Switch Window    ${handles}[1]
    [Return]   ${transactionCount}

Login to Rusty
    Input Text When Element Is Visible    ${ipt_user}    ${rusty_user}
    Input Text When Element Is Visible    ${ipt_pwd}    ${rusty_pwd}
    IF    '${captha_accepted}' == 'No'
            Click Element When Visible    //*[@id="onetrust-accept-btn-handler"]
            ${captha_accepted}   Set Variable     Yes
            Set Global Variable    ${captha_accepted}
    END
    Click Element When Visible    ${btn_login2}

Loop and Look for transactions
    [Arguments]   ${transactionCount}    ${submitCounter}
    FOR    ${counter}    IN RANGE    1    20   
        TRY
            Switch Window    ${handles}[0]
            ${PaymentAmount}=   Get Value    //input[@id='PaymentAmount${submitCounter}']
            ${PaymentAccount}=   Get Value    //input[@id='PaymentAccount${submitCounter}']
            Switch Window    ${handles}[1]
            Click Element When Visible    ${AccountLocators}[${PaymentAccount}]
            Input Text When Element Is Visible    //input[@class="dataTable-input"]    ${PaymentAmount}
            ${Supplier}   Get Text    xpath=(//td)[5]
        EXCEPT 
            Click Element When Visible    ${btn_error}
            Login to Rusty
            Exit For Loop
        END
        Switch Window    ${handles}[0]
        Input Text When Element Is Visible    //input[@id='Supplier${submitCounter}']    ${Supplier}
        ${submitCounter}   Evaluate    ${submitCounter}+1
        Exit For Loop If    '${submitCounter}' == '13'
    END
    [Return]  ${submitCounter}

*** Tasks ***
Minimal task
    ${transactionCount}   Open Browser tabs and count Transactions
    Login to Rusty
    FOR    ${counter}    IN RANGE    1    ${transactionCount}
        ${submitCounter}   Loop and Look for transactions   ${transactionCount}    ${submitCounter}
        Exit For Loop If    '${submitCounter}' == '13'
    END    
    Click Element When Visible    //button[@id='submitChallenge']
