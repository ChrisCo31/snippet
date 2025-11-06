Sub CopierTousLesProjets()
    Dim ws As Worksheet
    Dim wsParams As Worksheet
    Dim projectName As String
    Dim ligneDestination As Long
    Dim derniereLigne As Long
    Dim derniereProjet As Long
    Dim i As Long, j As Long
    Dim projetsAjoutes As String
    Dim compteurAjoutes As Integer

    ' D�finir les feuilles
    Set ws = ActiveSheet
    Set wsParams = ThisWorkbook.Sheets("Parameters")

    ' Initialisation
    projetsAjoutes = ""
    compteurAjoutes = 0

    ' Trouver la derni�re ligne de la liste des projets (depuis H27)
    derniereProjet = wsParams.Cells(wsParams.Rows.Count, "H").End(xlUp).Row

    ' Boucle sur chaque projet (commence � H27)
    For i = 27 To derniereProjet
        projectName = Trim(wsParams.Cells(i, "H").Value)

        ' Ignorer les cellules vides
        If projectName <> "" Then
            ' S�lectionner le projet dans B4
            ws.Range("B4").Value = projectName

            ' Attendre mise � jour (si formules)
            Application.Calculate
            DoEvents

            ' Trouver la ligne destination dans le tableau
            derniereLigne = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
            ligneDestination = 0

            For j = 1 To derniereLigne
                If ws.Cells(j, "A").Value = projectName Then
                    ligneDestination = j
                    Exit For
                End If
            Next j

            ' Si le projet n'existe pas, le cr�er
            If ligneDestination = 0 Then
                derniereLigne = derniereLigne + 1
                ws.Cells(derniereLigne, "A").Value = projectName
                ligneDestination = derniereLigne

                ' Logger le projet ajout�
                projetsAjoutes = projetsAjoutes & "- " & projectName & vbCrLf
                compteurAjoutes = compteurAjoutes + 1
            End If

            ' Copier les valeurs
            ws.Cells(ligneDestination, "B").Value = ws.Range("D4").Value
            ws.Cells(ligneDestination, "C").Value = ws.Range("E4").Value
            ws.Cells(ligneDestination, "D").Value = ws.Range("F4").Value
            ws.Cells(ligneDestination, "E").Value = ws.Range("G4").Value
            ws.Cells(ligneDestination, "F").Value = ws.Range("H4").Value
            
            ' Formatage des colonnes montants (B:E) - gras + euros + n�gatifs rouges + align� droite
            With ws.Range(ws.Cells(ligneDestination, "B"), ws.Cells(ligneDestination, "E"))
                .Font.Bold = True
                .NumberFormat = "#,##0 �;[Red]-#,##0 �"
                .HorizontalAlignment = xlRight
            End With

            ' Formatage colonne pourcentage (F) - gras + 2 d�cimales + align� droite
            With ws.Cells(ligneDestination, "F")
                .Font.Bold = True
                .NumberFormat = "0.0%"
                .HorizontalAlignment = xlRight
            End With
        End If
    Next i

    ' Message final
    Dim message As String
    message = "Toutes les valeurs ont ete copiees avec succes!"

    If compteurAjoutes > 0 Then
        message = message & vbCrLf & vbCrLf & _
                  compteurAjoutes & " nouveau(x) projet(s) ajoute(s):" & vbCrLf & _
                  projetsAjoutes
    End If

    MsgBox message, vbInformation, "Copie terminee"
End Sub

