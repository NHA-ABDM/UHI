# Header_generator

It's a utility to generate signing key pairs, generating headers and verification of UHI headers.

## Getting started

### Pre-Requisite -
	 Java 8 or above installed on machine
### How to run - 
		1. Open the cmd terminal on java/bin path like - C:\Users\10696314\Downloads\openjdk-17.0.1_windows-x64_bin\jdk-17.0.1\bin>
		2. Enter the below command to run the jar file
			`java -jar "path of jar file"`
			like - java -jar C:\Users\10696314\Documents\header_generator\target\header_generator-0.0.1-SNAPSHOT.jar<br>
		
![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/header_generator/Main_screen.png)

	  After successful run it will show below three option
		1. Key pair generation
		2. Signed header generation
		3. Signed header verfication

		1. Key pair generation - This option is to generate ed25519 public & private key pair.
		
![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/header_generator/option1.png?raw=true)
		
		2. Signed header generation - This option is to generate signed header which should include during gateway /search
		
![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/header_generator/option2.png?raw=true)
		
		 3. Signed header verfication - This option is to verify above generated header. True - verified/successful, False - Not verified
		
![alt text](https://github.com/NHA-ABDM/UHI/blob/main/assets/header_generator/option3.png?raw=true)
