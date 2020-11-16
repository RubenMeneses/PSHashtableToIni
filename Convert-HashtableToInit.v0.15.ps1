

Function Convert-HashtableToIni {

        Param(  
            [Hashtable]$InputObject,
            $eol_delimiter="`r`n",
            $section_name="",
            $child_prefix="child_"
        )  

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
                
                #add delimiter at end
                $child_section_content=$eol_delimiter+$child_section_content
                
                if (-not $empty_section_name) {
                    $section_body+=$key+"="+$child_section_name+$eol_delimiter
                }
            } 
            else {
                $section_body+=$key+"="+$val+$eol_delimiter
            }
        }
        
        #build heading
        $section_heading="[$section_name]" +"$eol_delimiter"

        #put everything togerther, if input section is not empty
        if (-not $empty_section_name) {
            $result=$section_heading+$section_body  
        }

        #$result=$result+$eol_delimiter+$child_section_content
        $result=$result+$child_section_content

        #Write-Host  $result
        return $result
}

#region create nested hashtable
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
    subjectAltName="DNS:10.10.10.10,DNS:10.10.10.12"
}

$config = @{}
$config.add("req",@{})
$config.req.add("encrypt_key","no")
$config.req.add("distinguished_name",$subjectPSObjc)
$config.req.add("prompt","no")

$config.add("v3_req",$v3_req)

#endregion

#convert 
$outputstringforfile=Convert-HashtableToIni -InputObject $config
Write-Host $outputstringforfile
