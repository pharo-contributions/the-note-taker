"
I am the toolbar command of The Note Taker that edits its settings.

## Life cycle: who creates me and who uses me

1. `NTNoteTakerMainUI class>>#buildNTContextualGroupWith:` creates me with the main presenter as context and puts me in the toolbar (shortcut Cmd+P).
2. When run, `execute` opens an `NTSettingsPresenter` on the settings of the `NTApplication` in a modal dialog.
3. When the user saves, I export the settings to the preferences file of the application (`NTApplication>>#exportSettings`).

## Responsibility:

- I open the settings editor on the settings of my application.
- I make the saved settings persistent.

## Collaborators:

- `NTApplication`: owns the settings and the preferences file.
- `NTSettingsPresenter`: the editor I open.

## Public API and Key Messages

- `execute`

## Examples

The editor I open is shown by:

```
NTSettingsPresenter scriptEditSettingsSavedInAStonFile
```
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

	^ 'Edit the settings of The Note Taker'
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
		  beDisplayedOnRightSide;
		  yourself
]

{ #category : 'executing' }
NTSpSettingsCommand >> execute [
	"Edit the settings of the application in a dialog, and save them in its preferences file when accepted"

	(self application instantiate: NTSettingsPresenter on: self application settings)
		whenAcceptedDo: [ self application exportSettings ];
		openModal
]
