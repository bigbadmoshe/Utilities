# https://github.com/GoogleChromeLabs/chrome-for-testing/blob/main/data/last-known-good-versions-with-downloads.json
# https://www.nuget.org/packages/selenium.webdriver
# https://www.nuget.org/packages/selenium.support
# https://developer.microsoft.com/microsoft-edge/tools/webdriver/

Import-Module "D:\Desktop\lib\net8.0\WebDriver.dll"

$Options = New-Object OpenQA.Selenium.Edge.EdgeOptions

$options = New-Object OpenQA.Selenium.Edge.EdgeOptions
$options.AddArgument("--headless=new")
$options.AddArgument("--window-size=1280,720")
$options.AddArgument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0")

$driver = New-Object OpenQA.Selenium.Edge.EdgeDriver("D:\Desktop\lib\msedgedriver.exe", $Options)
$driver.Navigate().GoToUrl("URL")
#$driver.Quit()
