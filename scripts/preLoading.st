#( 'Microdown' ) do: [ :name |
		(IceRepository repositoryNamed: name)
			ifNil: [ self inform: 'Project not found: ' , name ]
			ifNotNil: [ :found |
				found
					unload;
					forget ] ].
	Smalltalk globals 
			at: #BaselineOfMicrodown 
			ifPresent: [ :c | c removeFromSystem ].		
"
'BaselineOfMicrodown' asPackage removeFromSystem
"
