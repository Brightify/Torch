Feature: Generate command
	Scenario: find entities in directory structure
		When I run `runtorch generate --no-timestamp ../SourceFiles/Directory`
		Then the file "../SourceFiles/Expected/EntitiesFromDirectory.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"
	Scenario: find entities in file
		When I run `runtorch generate --no-timestamp ../SourceFiles/MultipleData.swift`
		Then the file "../SourceFiles/Expected/MultipleData.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"
	Scenario: in directory
		When I run `runtorch generate --no-timestamp --output .  ../SourceFiles/Directory`
		Then the file "../SourceFiles/Expected/StandaloneData.swift" should be equal to file "Data+Torch.swift"
		And the file "../SourceFiles/Expected/StandaloneData2.swift" should be equal to file "Data2+Torch.swift"
	Scenario: output specified
		When I run `runtorch generate --no-timestamp --output Actual.swift ../SourceFiles/MultipleData.swift`
		Then the file "../SourceFiles/Expected/MultipleData.swift" should be equal to file "Actual.swift"
	Scenario: libraries
		When I run `runtorch generate --no-timestamp --libraries Foundation,UIKit ../SourceFiles/Directory/Data.swift`
		Then the file "../SourceFiles/Expected/Libraries.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"
	Scenario: non existing input file
		When I run `runtorch generate non_existing_file.swift`
		Then the output should contain:
		"""
		Could not read contents of `non_existing_file.swift`
		"""
	Scenario: no-header
		When I run `runtorch generate --no-header ../SourceFiles/Directory/Data.swift`
		Then the file "../SourceFiles/Expected/NoHeader.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"
	Scenario: in file with file-prefix
		When I run `runtorch generate --no-timestamp --file-prefix Torch --output Actual.swift ../SourceFiles/Directory/Data.swift`
		Then the file "../SourceFiles/Expected/Data.swift" should be equal to file "Actual.swift"
	Scenario: in directory with file-prefix
		When I run `runtorch generate --no-timestamp --file-prefix Torch --output . ../SourceFiles/Directory`
		Then the file "../SourceFiles/Expected/StandaloneData.swift" should be equal to file "TorchData+Torch.swift"
		And the file "../SourceFiles/Expected/StandaloneData2.swift" should be equal to file "TorchData2+Torch.swift"
	Scenario: in file with file-suffix
		When I run `runtorch generate --no-timestamp --file-suffix Suffix --output Actual.swift ../SourceFiles/Directory/Data.swift`
		Then the file "../SourceFiles/Expected/Data.swift" should be equal to file "Actual.swift"
	Scenario: in directory with file-suffix
		When I run `runtorch generate --no-timestamp --file-suffix Suffix --output . ../SourceFiles/Directory`
		Then the file "../SourceFiles/Expected/StandaloneData.swift" should be equal to file "DataSuffix.swift"
		And the file "../SourceFiles/Expected/StandaloneData2.swift" should be equal to file "Data2Suffix.swift"
	Scenario: real data
		When I run `runtorch generate --no-timestamp ../SourceFiles/RealData.swift`
		Then the file "../SourceFiles/Expected/RealData.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"