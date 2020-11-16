Function Convert-HashtableToIni {
        Param(
            [Hashtable]$InputObject,
            $eol_delimiter="`r`n",
            $section_name="",
            $child_prefix="child_"
        )
        
        #init var
        $section_body=""

        #Test for empty section parameter
        if ([System.String]::IsNullOrEmpty($section_name)) { $empty_section_name = $true  } else {$empty_section_name = $false}


        foreach ($i in $InputObject.GetEnumerator())
        {
            $key=$i.name
            $val=$i.value
            $val_type=$i.value.GetType().Name
            

            if ($val_type -eq "Hashtable")
            {
                #if input section is not empty
                if ($empty_section_name) {
                    $child_section_name = $key
                }
                else {
                    $child_section_name = $child_prefix+$key
                }
                #extract content from child
                $child_section_content=Convert-HashtableToIni -InputObject $val -section_name $child_section_name -child_prefix $child_prefix -eol_delimiter $eol_delimiter
                write-host $child_section_content
                
                #add delimiter at end
                $child_section_content=$eol_delimiter+$child_section_content

                if (-not $empty_section_name) {
                    $section_body=$section_body+$key+"="+$child_section_name+$eol_delimiter
                }
            }
            else {
                $section_body=$section_body+$key+"="+$val+$eol_delimiter
            }
        }

        #build heading string
        $section_heading="[$section_name]" +"$eol_delimiter"

        #put heading and body togerther, if input section is not empty
        if (-not $empty_section_name) {
            $result=$section_heading+$section_body
        }
        
        #Build result string, add to previous
        $result=$result+$child_section_content

        return $result
}

$subjectPSObjc=@{
    C = "NZ"
    ST = "Auckland"
    L = "Auckland"
    O = "My Oh no."
	OU = "My OU."
    CN = "www.mydom.com"
    emailAddress= "bob@hotmail.com"
}

$v3_req=@{
    extendedKeyUsage= "serverAuth,clientAuth"
    keyUsage="keyEncipherment, dataEncipherment"
    subjectAltName="DNS:10.10.10.10,DNS:10.10.10.12,,DNS:mydom.com"
}

$config = @{
    req=@{
        "encrypt_key"="no"
        distinguished_name=$subjectPSObjc
        req_extensions=@{
            v3_req=$v3_req
        }
    }
}


$outputstringforfile=Convert-HashtableToIni -InputObject $config
#Write-Host $outputstringforfile
Out-File -InputObject $outputstringforfile -FilePath "D:\Google Drive\Powershell\modules\Convert-HashtableToIni\testoutput.log" -Force -Encoding Ascii
