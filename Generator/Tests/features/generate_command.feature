Feature: Generate command
	Scenario: find entities in directory structure
		When I run `runtorch generate --no-timestamp ../SourceFiles/Directory`
		Then the file "../SourceFiles/Expected/EntitiesFromDirectory.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"
	Scenario: find entities in file
		When I run `runtorch generate --no-timestamp ../SourceFiles/MultipleData.swift`
		Then the file "../SourceFiles/Expected/MultipleData.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"
	Scenario: in directory
		When I run `runtorch generate --no-timestamp --output .  ../SourceFiles/Directory`
		Then the file "../SourceFiles/Expected/Data.swift" should be equal to file "Data.swift"
		And the file "../SourceFiles/Expected/Data2.swift" should be equal to file "Data2.swift"
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
		Then the file "../SourceFiles/Expected/Data.swift" should be equal to file "TorchData.swift"
		And the file "../SourceFiles/Expected/Data2.swift" should be equal to file "TorchData2.swift"
	Scenario: entity-name-prefix
		When I run `runtorch generate --no-timestamp --entity-name-prefix CustomPrefix ../SourceFiles/Directory/Data.swift`
		Then the file "../SourceFiles/Expected/EntityNamePrefix.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"
	Scenario: real data
		When I run `runtorch generate --no-timestamp ../SourceFiles/RealData.swift`
		Then the file "../SourceFiles/Expected/RealData.swift" should be equal to file "GeneratedTorchEntityExtensions.swift"