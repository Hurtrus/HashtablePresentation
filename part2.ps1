# The fun stuff
# Ordered hashtables
$person = [ordered]@{
    name = 'Kevin'
    age  = 37
}


# Inline
$person = @{ name = 'kevin'; age = 37; }


# Custom expressions in common pipeline commands
$drives = Get-PSDrive | Where Used
$drives | Get-Member
$drives | Select-Object Name, @{n = 'totalSpaceGB'; e = { ($_.used + $_.free) / 1GB }}


# Expanded
$property = @{
    name       = 'totalSpaceGB'
    expression = { ($_.used + $_.free) / 1GB }
}

$drives | Select-Object Name, $property


# Splatting
Add-DhcpServerv4Scope -Name 'TestNetwork' -StartRange '10.0.0.2' -EndRange '10.0.0.254' -SubnetMask '255.255.255.0' -Description 'Network for testlab A' -LeaseDuration (New-TimeSpan -Days 8) -Type "Both"


$DHCPScope = @{
    Name          = 'TestNetwork'
    StartRange    = '10.0.0.2'
    EndRange      = '10.0.0.254'
    SubnetMask    = '255.255.255.0'
    Description   = 'Network for testlab A'
    LeaseDuration = (New-TimeSpan -Days 8)
    Type          = "Both"
}
Add-DhcpServerv4Scope @DHCPScope


# Splatting optional values
$CIMParams = @{
    ClassName    = 'Win32_Bios'
    ComputerName = $ComputerName
}

if ($null -ne $Credential)
{
    $CIMParams.Credential = $Credential
}

Get-CIMInstance @CIMParams


# Adding hashtables (once)
$person += @{Zip = '78701'}


# Nested hashtables
$person = @{
    name = 'Kevin'
    age  = 37
}
$person.location = @{}
$person.location.city = 'Irvine'
$person.location.state = 'CA'


$person = @{
    name     = 'Kevin'
    age      = 37
    location = @{
        city  = 'Irvine'
        state = 'CA'
    }
}

$person.location.city

# more nesting
$people = [ordered]@{
    Kevin = @{
        age  = 37
        city = 'Irvine'
    }
    Alex  = @{
        age  = 9
        city = 'Irvine'
    }
}

$people.Kevin.age
$people.Kevin['city']
$people['Alex'].age
$people['Alex']['city']


# Walking the list
foreach ($name in $people.keys)
{
    $person = $people[$name]
    '{0}, age {1}, is in {2}' -f $name, $person.age, $person.city
}


# Looking at nested hashtables
$people

$people | ConvertTo-Json

# Creating arrays of hashtables
$peopleArray = @(
    @{
        name = 'Kevin'
        age  = 37
        city = 'Irvine'
    }
    @{
        name = 'Alex'
        age  = 9
        city = 'Irvine'
    }
)
$peopleArray | ConvertTo-Json

# Sorting arrays of hashtables
$peopleArray | Sort-Object Name # incorrect
$peopleArray | Sort-Object @{e={$_.name}}

# Creating objects
$person = [pscustomobject]@{
    name = 'Kevin'
    age  = 36
}
$person


# late casting
$person = @{
    name = 'Kevin'
    age  = 36
}

[pscustomobject]$person

# sorting cast to pscustombojects and sort
$peopleArray | ForEach-Object {[pscustomobject]$PSItem} |
    Sort-Object Name


# Saving to CSV
$person | ForEach-Object { [pscustomobject]$PSItem } |
    Export-CSV -Path $path


# Saving nested hashtable to file
$people | ConvertTo-JSON | Set-Content -Path $path
$people = Get-Content -Path $path -Raw | ConvertFrom-JSON


# Convert JSON to Hashtable (PS 5)
[Reflection.Assembly]::LoadWithPartialName("System.Web.Script.Serialization")
$JSSerializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
$JSSerializer.Deserialize($json, 'Hashtable')

# Convert JSON to Hashtable (PS 6)
$json = $people | ConvertTo-JSON
$hashtable = $json | ConvertFrom-Json -AsHashtable
$hashtable

# Read directly from a file
$path = '.\data\person.psd1'
$content = Get-Content -Path $Path -Raw -ErrorAction Stop
$scriptBlock = [scriptblock]::Create( $content )
$scriptBlock.CheckRestrictedLanguage( $allowedCommands, $allowedVariables, $true )
$hashtable = ( & $scriptBlock )

# Magic using transformation attributes
# https://kevinmarquette.github.io/2017-02-20-Powershell-creating-parameter-validators-and-transforms/
[Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
$hashtable = '.\data\person.psd1'
$hashtable


# Reminder, keys are just strings
$person = @{
    'full name' = 'Kevin Marquette'
    '#'         = 3978
}
$person['full name']

$person.'full name'

$key = 'full name'
$person.$key


# Pass by refference and Shallow copies
# value types
$orig = "Original"
$copy = $orig
'Orig: [{0}]' -f $orig
'Copy: [{0}]' -f $copy

$copy = "The Copy"
'Orig: [{0}]' -f $orig
'Copy: [{0}]' -f $copy


# Reference types
$orig = @{name = 'Original'}
$copy = $orig
'Orig: [{0}]' -f $orig.name
'Copy: [{0}]' -f $copy.name

$copy.name = 'The Copy'
'Orig: [{0}]' -f $orig.name
'Copy: [{0}]' -f $copy.name



# Shallow copies, single level
$orig = @{name = 'Original'}
$copy = $orig.Clone()
'Orig: [{0}]' -f $orig.name
'Copy: [{0}]' -f $copy.name

$copy.name = 'The Copy'
'Orig: [{0}]' -f $orig.name
'Copy: [{0}]' -f $copy.name



# Shallow copies, nested
$orig = @{
    person = @{
        name = 'Original'
    }
}
$copy = $orig.Clone()
'Orig: [{0}]' -f $orig.person.name
'Copy: [{0}]' -f $copy.person.name

$copy.person.name = 'The Copy'
'Orig: [{0}]' -f $orig.person.name
'Copy: [{0}]' -f $copy.person.name

