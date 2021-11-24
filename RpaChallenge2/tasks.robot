*** Settings ***
Documentation   RPA Challenge 2
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.Browser.Playwright
Library    RPA.PDF
Library    RPA.FileSystem
Library    RPA.Archive
Library    RPA.Dialogs
Library    Dialogs
Library    RPA.Robocorp.Vault

*** Variables ***
${URL}    
${url_Excel}    https://robotsparebinindustries.com/orders.csv
@{orders}
${row}
${Head_as_int}
${Element}
${order_receipt}
${screenshot}
${Directory}    Receipts
${DirectPNG}    screenshot

*** Keywords ***
Open the robot order website
    ${URL}=         Get Secret    Vault
    ${URL}=    Set Variable    ${URL}[robot_url]
    New Browser    chromium    headless=false
    New Context    viewport={'width': 1920, 'height': 1080}    acceptDownloads=true
    New Page    ${URL}

*** Keywords ***
Download Csv File
    ${url_Excel}=    Get Value From User    What is the URL of the orders CSV file?
    RPA.HTTP.Download     ${url_Excel}    overwrite=True

*** Keywords ***
Get orders
    ${orders}=    Read Table From Csv    orders.csv    headers=True 
    [Return]    ${orders}
*** Keywords ***
Fill the form 
    [Arguments]    ${row}
    #Click   "head"    
    Select Options By    css=#head    value    ${row}[Head]
    Check Checkbox       id=id-body-${row}[Body] 
    Type Text            //*[@class="form-control"]   ${row}[Legs]
    Type Text    id=address    ${row}[Address]

Close the annoying modal
    Click    "OK"

Preview the robot
    Click    id=preview


Try to submit the order
    Click    //*[@id="order"]

    ${order_results_html}=    Get Property    //*[@id="receipt"]    outerHTML



Submit the order

    # klik op order knop, maar dat kan fout gaan dus meerdere pogingen

    Wait Until Keyword Succeeds    10x    1 s    try to submit the order

Store the receipt as a PDF file
    [Arguments]     ${row}
    ${Ordernummer}=    Set Variable    ${row}[Order number]
    ${order_results_html}=    Get Property    //*[@id="receipt"]    outerHTML
    Html To Pdf    ${order_results_html}    ${Directory}${/}${Ordernummer}.pdf


Take a screenshot of the robot
    [Arguments]    ${row}
    ${screenshot}=    Take Screenshot    ${row}[Order number]    //*[@id="robot-preview"]
    Open Pdf    ${Directory}${/}${row}[Order number].pdf
    Add Watermark Image To Pdf    ${screenshot}    ${Directory}${/}${row}[Order number].pdf

Embed the robot screenshot to the receipt PDF file

Go to order another robot
    Click    //*[@id="order-another"]

Create a ZIP file of the receipts
    Archive Folder With Zip    ${Directory}    ZIPReceipts.zip
    

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download Csv File
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}
        ${screenshot}=    Take a screenshot of the robot    ${row}
        #Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts

