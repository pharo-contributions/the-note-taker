Class {
	#name : 'NTISOFileNamerTest',
	#superclass : 'TestCase',
	#category : 'TheNoteTaker-Tests-Support-Resources',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Support-Resources'
}

{ #category : 'tests' }
NTISOFileNamerTest >> testDefaultNameSetDifferently [

	| namer |
	namer := NTISOFileNamer new defaultEmptyName: 'Unknown.md'.
	namer date: (Date newDay: 7 month: 12 year: 2024).
	self assert: namer newName equals: '2024-12-07_Unknown.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNameWithNameAlreadyTagged [

	| namer priorName name |
	namer := NTISOFileNamer new.
	priorName := '2024-02-03' , namer separatorString , 'Unknown.md'.
	name := namer newNameBasedOn: priorName.
	self assert: name equals: priorName
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewName [

	| namer |
	namer := NTISOFileNamer new.
	namer date: (Date readFrom: '2024-11-02' readStream pattern: 'y-m-d').
	
	self 
		assert: (namer newNameBasedOn: 'Unknown.md')  
		equals: '2024-11-02_Unknown.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewNameWithNoExtension [

	| namer |
	namer := NTISOFileNamer new.
	namer date: (Date readFrom: '2024-11-02' readStream pattern: 'y-m-d').
	
	self 
		assert: (namer newNameBasedOn: 'Unknown')  
		equals: '2024-11-02_Unknown.md'
]

{ #category : 'tests' }
NTISOFileNamerTest >> testNewNameWithNoExtensionButPartsShouldStartWithDate [

	| namer |
	namer := NTISOFileNamer new.
	namer date: (Date readFrom: '2024-11-02' readStream pattern: 'y-m-d').

	self
		assert: (namer newNameBasedOn: '2024-11-02_part12_part34_part56 78')
		equals: '2024-11-02_part12_part34_part5678.md'
]

{ #category : 'tests - revert' }
NTISOFileNamerTest >> testTitleFromFileName [

	self
		assert: (NTISOFileNamer new titleFromParts:
				 ('2024-11-02_ThisIsATitle_Zork Zork' splitOn: '_') allButFirst)
		equals: 'ThisIsATitle_ZorkZork'
]

{ #category : 'tests - revert' }
NTISOFileNamerTest >> testTitleFromFileNameBadDate [

	self 
		assert: (NTISOFileNamer new extractBaseNameFrom: 'YYgjghjgjhg_Unknown.md')
		equals: 'Unknown'
	
		
]

{ #category : 'tests - revert' }
NTISOFileNamerTest >> testTitleFromFileNameBadEndEmpty [

	self
		assert: (NTISOFileNamer new extractBaseNameFrom: ('2024-11-02_' withoutSuffix: '.md'))
		equals: 'unnamed'
]

{ #category : 'tests - revert' }
NTISOFileNamerTest >> testTitleFromFileNameBadEndNotAlphanumerical [

	self
		assert:
		(NTISOFileNamer new extractBaseNameFrom: '2024-11-02_!!/\.md')
		equals: 'unnamed'
]
