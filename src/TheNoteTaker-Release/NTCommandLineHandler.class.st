Class {
	#name : 'NTCommandLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'TheNoteTaker-Release',
	#package : 'TheNoteTaker-Release'
}

{ #category : 'accessing' }
NTCommandLineHandler class >> commandName [

	^ 'noteTaker'
]

{ #category : 'building' }
NTCommandLineHandler class >> generateApplication [
	<script: 'self generateApplication'>
	
	(self environment at: #AppGeneratorOSXGenerator) new
		properties: { 
        #AppName -> 'NoteTaker' .
        #InfoString -> 'A note taking application written in Pharo' .
        #BundleIdentifier -> 'org.pharo.notetaker' .
        #ShortVersion -> '1.0.0' .
        #DisplayName -> 'Note Taker' .
        #CommandLineHandler -> 'noteTaker' .
        #CompanyName -> 'INRIA' } asDictionary;
		outputDirectory: FileLocator workingDirectory / 'build';
		generate.
]

{ #category : 'activation' }
NTCommandLineHandler >> activate [

	OSWindowDriver current startUp: true.
	
	AppGeneratorSupport errorHandler: AppGeneratorSDLMessageErrorHandler new.
	NTSpApplication new start.
]
