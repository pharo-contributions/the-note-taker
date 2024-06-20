Class {
	#name : 'NTCommandLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'TheNoteTaker-Base',
	#package : 'TheNoteTaker',
	#tag : 'Base'
}

{ #category : 'building' }
NTCommandLineHandler class >> build [

	(self environment at: #EmbeddedSupportOSXGenerator) new
		properties: { 
        #AppName -> 'NoteTaker' .
        #InfoString -> 'A note taking application written in Pharo' .
        #BundleIdentifier -> 'org.pharo.notetaker' .
        #ShortVersion -> '1.0.0' .
        #DisplayName -> 'Note Taker' .
        #CommandLineHandler -> 'note' .
        #CompanyName -> 'INRIA' } asDictionary;
		outputDirectory: FileLocator workingDirectory / 'build';
		generate.
]

{ #category : 'accessing' }
NTCommandLineHandler class >> commandName [

	^ 'note'
]

{ #category : 'activation' }
NTCommandLineHandler >> activate [

	OSWindowDriver current startUp: true.
	NTSpApplication new start.
]
