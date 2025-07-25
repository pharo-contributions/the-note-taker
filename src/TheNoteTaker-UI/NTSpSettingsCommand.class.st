"
Command for open a Settings Browser with TheNoteTaker options.
"
Class {
	#name : 'NTSpSettingsCommand',
	#superclass : 'NTSpAbstractCommand',
	#category : 'TheNoteTaker-UI-Commands',
	#package : 'TheNoteTaker-UI',
	#tag : 'Commands'
}

{ #category : 'default' }
NTSpSettingsCommand class >> defaultDescription [

	^ 'Open a Settings Browser'
]

{ #category : 'default' }
NTSpSettingsCommand class >> defaultName [

	^ 'Open settings'
]

{ #category : 'converting' }
NTSpSettingsCommand >> asSpecCommand [

	^ super asSpecCommand
		  iconName: #smallConfiguration;
		  shortcutKey: $P meta;
		  yourself
]

{ #category : 'executing' }
NTSpSettingsCommand >> execute [

	"self application registerWindow:" (SettingBrowser new
			 rootNodes:
				 (SettingBrowser currentTree nodeNamed: #tnt) allChildren;
			 open)
]
