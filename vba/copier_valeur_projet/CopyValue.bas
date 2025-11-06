Sub CopierValeursProjet()
    Dim ws As Worksheet
    Dim projectName As String
    Dim ligneDestination As Long
    Dim derniereLigne As Long

    ' Définir la feuille active
    Set ws = ActiveSheet

    ' Récupérer le nom du projet depuis B4
    projectName = ws.Range("B4").Value

    ' Vérifier que B4 n'est pas vide
    If projectName = "" Then
        MsgBox "Veuillez sélectionner un projet dans B4", vbExclamation
        Exit Sub
    End If

    ' Trouver la dernière ligne avec des données en colonne A
    derniereLigne = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row

    ' Chercher le projet dans la colonne A du tableau
    ligneDestination = 0
    For i = 1 To derniereLigne
        If ws.Cells(i, "A").Value = projectName Then
            ligneDestination = i
            Exit For
        End If
    Next i

    ' Si le projet est trouvé, copier les valeurs
    If ligneDestination > 0 Then
        ws.Cells(ligneDestination, "B").Value = ws.Range("D4").Value
        ws.Cells(ligneDestination, "C").Value = ws.Range("E4").Value
        ws.Cells(ligneDestination, "D").Value = ws.Range("F4").Value
        ws.Cells(ligneDestination, "E").Value = ws.Range("G4").Value
        ws.Cells(ligneDestination, "F").Value = ws.Range("H4").Value

        MsgBox "Valeurs copiées avec succès pour " & projectName, vbInformation
    Else
        MsgBox "Projet '" & projectName & "' non trouvé dans le tableau", vbCritical
    End If
End Sub