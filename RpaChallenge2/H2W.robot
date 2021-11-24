*** Settings ***
Library    DateTime
Library    String


*** Variables ***
${Vandaag}

*** Keywords ***
Laatste dag van de maand in NL formaat
    ${Vandaag}=    Get Current Date
    ${Vandaag}=    Add Time To Date    date    time
    Log To Console        ${Vandaag}


*** Tasks ***
task
    Laatste dag van de maand in NL formaat