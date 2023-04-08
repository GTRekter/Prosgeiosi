# Desscription: This script defines a DSC configuration called WebServer, 
# which installs the IIS web server feature, creates a new IIS website, and creates an HTML file 
# for the website's default page.
configuration WebServer
{
    # Import the xWebAdministration DSC resource module
    Import-DscResource -ModuleName xWebAdministration

    # Install the IIS web server feature
    WindowsFeature WebServer
    {
        Ensure = "Present"
        Name = "Web-Server"
    }

    # Create a new IIS website
    xWebsite DefaultSite
    {
        Ensure   = "Present"
        Name     = "Default Web Site"
        PhysicalPath = "C:\inetpub\wwwroot"
        BindingInfo = MSFT_xWebBindingInformation
        {
            Protocol = "HTTP"
            Port     = "80"
        }
    }

    # Create an HTML file for the new website
    File DefaultPage
    {
        Ensure          = "Present"
        Type            = "File"
        DestinationPath = "C:\inetpub\wwwroot\index.html"
        Contents        = "<html><body><h1>Welcome to my website!</h1></body></html>"
    }
}

# Invoke the WebServer configuration to apply the DSC configuration
WebServer -OutputPath .\WebServer

# Test the configuration to ensure it was applied successfully
Start-DscConfiguration -Path .\WebServer -Wait -Verbose
