Sub Main
    Debug.Clear
    
    Dim App As femap.model
    Set App = feFemap()
    
    Dim feNode As femap.Node
    Dim nodeSet As femap.Set
    Dim feElem As femap.Elem
    
    Dim t1 As Double
    Dim e1 As Double
    
    Dim sucuSet As femap.Set
    Set sucuSet = App.feSet
    
    Dim sucuSet2 As femap.Set
    Set sucuSet2 = App.feSet
    
    Set nodeSet = App.feSet()
    
    Dim cuSet As femap.Set
    Set cuSet = App.feSet
    
    Set feNode = App.feNode
    Set feElem = App.feElem
    Set nodeSet = App.feSet()
    
    Dim cuID As Long
    Dim suID As Long
    
    Dim feCurve As femap.Curve
    Set feCurve = App.feCurve
    
    Dim t2 As Double
    Dim e2 As Double
    
    Dim fesurf As femap.Surface
    Dim su1 As femap.Set
    Set fesurf = App.feSurface
    Set su1 = App.feSet
    
    Dim cuCenter As Variant
    Dim el1 As femap.Set
    Dim cuNormal As Variant
    Set el1 = App.feSet
    
    Dim cuStartPt As Variant
    Dim su2 As femap.Set
    Dim cuEndPt As Variant
    Set su2 = App.feSet
    
    Dim cuAngle As Double
    Dim el2 As femap.Set
    Dim cuRadius As Double
    Set el2 = App.feSet
    
    Dim pt1(3) As Double
    Dim pr As femap.Prop
    Dim pt2(3) As Double
    Set pr = App.feProp
    
    Dim mt As femap.Matl
    Set mt = App.feMatl
    
    Dim mt2 As femap.Matl
    Set mt2 = App.feMatl
    
    Dim sl1 As femap.Set
    Set sl1 = App.feSet
    
    Dim nodeCount As Long
    Dim nodeX As Double
    Dim nodeY As Double
    Dim nodeZ As Double
    Dim nodeID As Long
    Dim elemID As Long
    Dim vNodeArray As Variant
    Dim RAD As Double
    
    Dim cu As femap.Curve
    Set cu = App.feCurve
    
    Dim suSet As femap.Set
    Set suSet = App.feSet
    
    Dim ptID1 As Long
    Dim ptID2 As Long
    
    Dim fePoint As femap.Point
    Set fePoint = App.fePoint
    
    Dim passCount As Long
    Dim nodeSet1 As femap.Set
    Set nodeSet1 = App.feSet()
    
    Dim nodeCount1 As Long
    Dim nodeX1 As Double
    Dim nodeY1 As Double
    Dim nodeZ1 As Double
    Dim nodeID1 As Long
    Dim elemID1 As Long
    Dim vNodeArray1 As Variant
    Dim passCount1 As Long
    
    Dim feProp As femap.Prop
    Set feProp = App.feProp
    
    Dim propSet As femap.Set
    Set propSet = App.feSet
    
    'Adding only Beam properties to the set for efficiency
    propSet.AddRule 41, FGD_PROP_BYTYPE
    
    Dim BeamArea As Double
    Dim Vec(3) As Variant
    Dim X As Double
    Dim Y As Double
    Dim Z As Double
    Dim X1 As Double
    Dim Y1 As Double
    Dim Z1 As Double
    Dim VecP As Variant
    
    Dim feMatl As femap.Matl
    Set feMatl = App.feMatl
    
    Dim matID As Long
    matID = App.Info_ActiveID(FT_MATL)
    
    If matID = 0 Then
        Msg = "No active material for fastener, please activate a material and re-run."
        rc = MsgBox(Msg, vbOKOnly, "No Material")
        GoTo Jumping_Out
    End If
    
    rc = feMatl.Get(matID)
    
DO_IT_AGAIN:
    RAD = 0.0
    nodeX = 0#
    nodeY = 0#
    nodeZ = 0#
    nodeX1 = 0#
    nodeY1 = 0#
    nodeZ1 = 0#
    
    'Get a set of nodes for this rigid element
    Dim issolid1 As Boolean
    Dim issolid2 As Boolean
    
    If MsgBox("Is body 1 a solid?", vbYesNo, "Set Solid Type") = vbYes Then
        issolid1 = True
    Else
        issolid1 = False
    End If
    
    If issolid1 = True Then
        rc = suSet.Clear
        rc = suSet.Select(FT_SURFACE, True, "Select surfaces at Fastener Bottom")
        If suSet.Count = 0 Then
            GoTo Jumping_Out
        End If
    Else
        rc = cuSet.Clear
        rc = cuSet.Select(FT_CURVE, True, "Select Curves at Fastener Bottom")
        If cuSet.Count = 0 Then
            GoTo Jumping_Out
        End If
    End If
    
    If issolid1 = True Then
        nodeCount = 0
        nodeX = 0#
        nodeY = 0#
        nodeZ = 0#
        
        'Get a set of nodes for this rigid element
        If suSet.Count = 0 Then
            GoTo Jumping_Out
        End If
        
        rc = nodeSet.AddSetRule(suSet.ID, FGD_NODE_ATSURFACE)
        
        If nodeSet.Count = 0 Then
            GoTo Jumping_Out
        End If
        
        'Lets see how many nodes were selected
        nodeCount = nodeSet.Count()
        If nodeCount > 0 Then
            'Walk the nodes and find the average
            rc = nodeSet.Reset()
            nodeID = nodeSet.Next()
            ReDim nodeArray(nodeCount) As Long
            passCount = 0
            
            Do While nodeID <> 0
                nodeArray(passCount) = nodeID
                passCount = passCount + 1
                rc = feNode.Get(nodeID)
                nodeX = nodeX + feNode.x
                nodeY = nodeY + feNode.y
                nodeZ = nodeZ + feNode.z
                nodeID = nodeSet.Next()
            Loop
            
            vNodeArray = nodeArray
            nodeID = feNode.NextEmptyID
            feNode.ID = nodeID
            feNode.x = nodeX / nodeCount
            feNode.y = nodeY / nodeCount
            feNode.z = nodeZ / nodeCount
            rc = feNode.Put(nodeID)
            
            If rc = -1 Then 'return code FE_OK
                'create the element
                elemID = feElem.NextEmptyID
                feElem.type = FET_L_RIGID
                feElem.topology = FTO_RIGIDLIST
                feElem.Node(0) = nodeID 'Independent Node
                feElem.release(0, 0) = 1
                feElem.release(0, 1) = 1
                feElem.release(0, 2) = 1
                feElem.ID = elemID
                rc = feElem.PutNodeList(0, nodeCount, vNodeArray, Null, Null, Null)
                rc = feElem.Put(elemID)
            End If
        End If
    Else
        cuID = cuSet.First
        rc = feCurve.Get(cuID)
        rc = nodeSet.Clear()
        rc = nodeSet.AddSetRule(cuSet.ID, FGD_NODE_ATCURVE)
        
        If rc = -1 Then 'return code FE_OK
            'Lets see how many nodes were selected
            nodeCount = nodeSet.Count()
            If nodeCount > 0 Then
                'Walk the nodes and find the average
                Set feNode = App.feNode()
                rc = nodeSet.Reset()
                nodeID = nodeSet.Next()
                ReDim nodeArray(nodeCount) As Long
                passCount = 0
                
                Do While nodeID <> 0
                    nodeArray(passCount) = nodeID
                    passCount = passCount + 1
                    rc = feNode.Get(nodeID)
                    nodeX = nodeX + feNode.x
                    nodeY = nodeY + feNode.y
                    nodeZ = nodeZ + feNode.z
                    nodeID = nodeSet.Next()
                Loop
                
                vNodeArray = nodeArray
                nodeID = feNode.NextEmptyID
                feNode.ID = nodeID
                feNode.x = nodeX / nodeCount
                feNode.y = nodeY / nodeCount
                feNode.z = nodeZ / nodeCount
                rc = feNode.Put(nodeID)
                
                If rc = -1 Then 'return code FE_OK
                    'create the element
                    Set feElem = App.feElem()
                    elemID = feElem.NextEmptyID
                    feElem.type = FET_L_RIGID
                    feElem.topology = FTO_RIGIDLIST
                    feElem.Node(0) = nodeID 'Independent Node
                    feElem.release(0, 0) = 1
                    feElem.release(0, 1) = 1
                    feElem.release(0, 2) = 1
                    feElem.ID = elemID
                    rc = feElem.PutNodeList(0, nodeCount, vNodeArray, Null, Null, Null)
                    rc = feElem.Put(elemID)
                End If
            End If
        End If
    End If
    
    Dim El As femap.Elem
    Set El = App.feElem
    Dim BeamElID As Long
    Dim PropID As Long
    Dim P As femap.Prop
    Set P = App.feProp
    Dim BeamID As Long
    
    'Solid 1 Properties extraction
    If issolid1 = False Then
        cuID = cuSet.First
        rc = feCurve.Get(cuID)
        rc = feCurve.ArcCircleInfo(cuCenter, cuNormal, cuStartPt, cuEndPt, cuAngle, cuRadius)
        PropID = 0
        RAD = cuRadius
        su1.AddRule cuID, FGD_SURFACE_BYCURVE
        rc = su1.First
        el1.AddRule su1.First, FGD_PROP_ONSURFACE
        pr.Get (el1.First)
        t1 = pr.pval(0)
        mt.ID = pr.matlID
        rc = mt.Get(mt.Ex)
        e1 = mt.Ex
    Else
        sucuSet.AddRule suSet.First, FGD_CURVE_ONSURFACE
        cuID = sucuSet.First
        While sucuSet.Next
            cu.ID = sucuSet.CurrentID
            cuID = cu.ID
            rc = cu.Get(cuID)
            rc = cu.ArcCircleInfo(cuCenter, cuNormal, cuStartPt, cuEndPt, cuAngle, cuRadius)
            If rc Then
                RAD = cuRadius
                msg = "radius = " + Format$(RAD)
                rc = App.feAppMessage(FCM_NORMAL, msg)
            Else
                t1 = cu.Length
                msg = "curve = " + Format$(cu.ID) + " Length = " + Format$(t1)
                rc = App.feAppMessage(FCM_NORMAL, msg)
            End If
        Wend
        
        rc = suSet.First
        sl1.AddRule suSet.First, FGD_SOLID_BYSURFACE
        rc = sl1.First
        el1.AddRule sl1.First, FGD_PROP_ONSOLID
        rc = el1.First
        pr.Get (el1.First)
        mt.ID = pr.matlID
        rc = mt.Get(mt.Ex)
        e1 = mt.Ex
    End If
    
    If MsgBox("Is body 2 a solid?", vbYesNo, "Set Body Type") = vbYes Then
        issolid2 = True
    End If
    
    If issolid2 = True Then
        rc = suSet.Clear
        rc = suSet.Select(FT_SURFACE, True, "Select surfaces at Fastener Top")
        If suSet.Count = 0 Then
            GoTo Jumping_Out
        End If
    Else
        rc = cuSet.Clear
        rc = cuSet.Select(FT_CURVE, True, "Select Curves at Fastener Top")
        If cuSet.Count = 0 Then
            GoTo Jumping_Out
        End If
    End If
    
    If issolid2 = True Then
        nodeCount = 0
        nodeX = 0#
        nodeY = 0#
        nodeZ = 0#
        
        'Get a set of nodes for this rigid element
        If suSet.Count = 0 Then
            GoTo Jumping_Out
        End If
        
        rc = nodeSet1.AddSetRule(suSet.ID, FGD_NODE_ATSURFACE)
        
        If nodeSet.Count = 0 Then
            GoTo Jumping_Out
        End If
        
        'Lets see how many nodes were selected
        nodeCount = nodeSet1.Count()
        If nodeCount > 0 Then
            'Walk the nodes and find the average
            rc = nodeSet1.Reset()
            nodeID1 = nodeSet1.Next()
            ReDim nodeArray(nodeCount) As Long
            passCount = 0
            
            Do While nodeID1 <> 0
                nodeArray(passCount) = nodeID1
                passCount = passCount + 1
                rc = feNode.Get(nodeID1)
                nodeX = nodeX + feNode.x
                nodeY = nodeY + feNode.y
                nodeZ = nodeZ + feNode.z
                nodeID1 = nodeSet1.Next()
            Loop
            
            vNodeArray = nodeArray
            nodeID1 = feNode.NextEmptyID
            feNode.ID = nodeID1
            feNode.x = nodeX / nodeCount
            feNode.y = nodeY / nodeCount
            feNode.z = nodeZ / nodeCount
            rc = feNode.Put(nodeID1)
            
            If rc = -1 Then 'return code FE_OK
                'create the element
                elemID = feElem.NextEmptyID
                feElem.type = FET_L_RIGID
                feElem.topology = FTO_RIGIDLIST
                feElem.Node(0) = nodeID1 'Independent Node
                feElem.release(0, 0) = 1
                feElem.release(0, 1) = 1
                feElem.release(0, 2) = 1
                feElem.ID = elemID
                rc = feElem.PutNodeList(0, nodeCount, vNodeArray, Null, Null, Null)
                rc = feElem.Put(elemID)
            End If
        End If
    Else
        'Get a set of nodes for this rigid element
        rc = nodeSet1.Clear()
        rc = nodeSet1.AddSetRule(cuSet.ID, FGD_NODE_ATCURVE)
        
        If rc = -1 Then 'return code FE_OK
            'Lets see how many nodes were selected
            nodeCount1 = nodeSet1.Count()
            If nodeCount1 > 0 Then
                'Walk the nodes and find the average
                Set feNode = App.feNode()
                rc = nodeSet1.Reset()
                nodeID1 = nodeSet1.Next()
                ReDim nodeArray1(nodeCount1) As Long
                passCount1 = 0
                
                Do While nodeID1 <> 0
                    nodeArray1(passCount1) = nodeID1
                    passCount1 = passCount1 + 1
                    rc = feNode.Get(nodeID1)
                    nodeX1 = nodeX1 + feNode.x
                    nodeY1 = nodeY1 + feNode.y
                    nodeZ1 = nodeZ1 + feNode.z
                    nodeID1 = nodeSet1.Next()
                Loop
                
                vNodeArray1 = nodeArray1
                nodeID1 = feNode.NextEmptyID
                feNode.ID = nodeID1
                feNode.x = nodeX1 / nodeCount1
                feNode.y = nodeY1 / nodeCount1
                feNode.z = nodeZ1 / nodeCount1
                rc = feNode.Put(nodeID1)
                
                If rc = -1 Then 'return code FE_OK
                    'create the element
                    Set feElem = App.feElem()
                    elemID = feElem.NextEmptyID
                    feElem.type = FET_L_RIGID
                    feElem.topology = FTO_RIGIDLIST
                    feElem.Node(0) = nodeID1 'Independent Node
                    feElem.release(0, 0) = 1
                    feElem.release(0, 1) = 1
                    feElem.release(0, 2) = 1
                    feElem.ID = elemID
                    rc = feElem.PutNodeList(0, nodeCount1, vNodeArray1, Null, Null, Null)
                    rc = feElem.Put(elemID)
                End If
            End If
        End If
    End If
    
    'solid 2 properties extraction
    If issolid2 = False Then
        cuID = cuSet.First
        rc = feCurve.Get(cuID)
        rc = feCurve.ArcCircleInfo(cuCenter, cuNormal, cuStartPt, cuEndPt, cuAngle, cuRadius)
        PropID = 0
        RAD = cuRadius
        su2.AddRule cuID, FGD_SURFACE_BYCURVE
        rc = su2.First
        el2.AddRule su2.First, FGD_PROP_ONSURFACE
        pr.Get (el2.First)
        t2 = pr.pval(0)
        mt2.ID = pr.matlID
        rc = mt2.Get(mt2.Ex)
        e2 = mt2.Ex
    Else
        sucuSet2.AddRule suSet.First, FGD_CURVE_ONSURFACE
        cuID = sucuSet2.First
        While sucuSet2.Next
            cu.ID = sucuSet2.CurrentID
            cuID = cu.ID
            rc = cu.Get(cuID)
            rc = cu.ArcCircleInfo(cuCenter, cuNormal, cuStartPt, cuEndPt, cuAngle, cuRadius)
            If rc Then
                RAD = cuRadius
                msg = "radius = " + Format$(RAD)
                rc = App.feAppMessage(FCM_NORMAL, msg)
            Else
                t2 = cu.Length
                msg = "curve = " + Format$(cu.ID) + " Length = " + Format$(t2)
                rc = App.feAppMessage(FCM_NORMAL, msg)
            End If
        Wend
        
        rc = suSet.First
        sl1.AddRule suSet.First, FGD_SOLID_BYSURFACE
        rc = sl1.First
        el1.AddRule sl1.First, FGD_PROP_ONSOLID
        rc = el1.First
        pr.Get (el1.First)
        mt2.ID = pr.matlID
        rc = mt2.Get(mt2.Ex)
        e2 = mt2.Ex
    End If
    
    Debug.Print (t1)
    Debug.Print (e1)
    Debug.Print (t2)
    Debug.Print (e2)
    
    'Calculating properties
    Dim h As Double
    Dim ef As Double
    Dim vf As Double
    Dim gf As Double
    
    h = (t1 + t2) / 2
    
    Dim fnmt As femap.Matl
    Set fnmt = App.feMatl
    
    Dim af As Double
    Dim I_f As Double
    Dim jf As Double
    
    fnmt.Get (matID)
    ef = fnmt.Ex
    vf = fnmt.Nuxy
    gf = fnmt.Gx
    
    af = 3.141592653 * RAD ^ 2
    I_f = 3.141592653 * ((RAD * 2) ^ 4) / 64
    jf = I_f * 2
    
    Dim ka As Double
    Dim ks As Double
    Dim kt As Double
    Dim kb As Double
    Dim a As Double
    Dim b As Double
    
    a = 2 / 3
    b = 3
    
    ka = ef * af / h
    ks = (((t1 + t2) / (A * RAD)) ^ a) * (((b) / (t1 * e1)) + ((b) / (t2 * e2)) + ((b) / (2 * t1 * e1)) + ((b) / (2 * t2 * e2)))
    kt = gf * jf / h
    kb = (ks ^ -1) * 100 * (h ^ 2) / 4
    
    Debug.Print (RAD)
    Debug.Print (gf)
    Debug.Print (jf)
    Debug.Print (af)
    Debug.Print (I_f)
    Debug.Print (ef)
    BeamArea = 3.141592653 * RAD * RAD
    
    'Resetting this since second loop on first usage causes the while loop to be passed and create a new element.
    propSet.Reset()
    
    'Looping through all properties in the set to check if BeamArea is already equal
    While propSet.Next
        PropID = propSet.CurrentID
        feProp.Get (PropID)
        If feProp.title = "API Fastener" Then
            If Abs(feProp.pval(0) - BeamArea) < 0.001 Then
                PropID = feProp.ID
                GoTo GOT_A_PROP
            End If
        Else
            'Remove the current property in the set if it does not match the title
            propSet.Remove (PropID)
        End If
    Wend
    
    PropID = P.NextEmptyID
    P.title = "API Fastener"
    P.type = 6
    P.flagI(3) = 1
    P.pval(36) = ka
    P.pval(37) = ks ^ -1
    P.pval(38) = ks ^ -1
    P.pval(39) = kt
    P.pval(40) = kb
    P.pval(41) = kb
    P.Put (PropID)
    
    'Add the new API Fastner Property to the set for comparison when selecting multiple.
    propSet.Add (PropID)
    
GOT_A_PROP:
    Msg = "Thickness 2  " + Format$(t1, "#.#") + " Fastener Diameter " + Format$(2 * cuRadius, "###.####") + ", Property " + Str$(PropID) + ", Material ID " + Str$(matID) + ", Titled " + feMatl.title
    rc = App.feAppMessage(FCM_NORMAL, Msg)
    
    BeamElID = El.NextEmptyID
    El.type = FET_L_SPRING
    El.Node(0) = nodeID
    El.Node(1) = nodeID1
    
    rc = feNode.Get(nodeID)
    X = feNode.x
    Y = feNode.y
    Z = feNode.z
    
    rc = feNode.Get(nodeID1)
    X1 = feNode.x
    Y1 = feNode.y
    Z1 = feNode.z
    
    Vec(0) = X - X1
    Vec(1) = Y - Y1
    Vec(2) = Z - Z1
    
    rc = App.feVectorPerpendicular(Vec, VecP)
    
    El.orient(0) = VecP(0)
    El.orient(1) = VecP(1)
    El.orient(2) = VecP(2)
    El.propID = PropID
    El.Put (BeamElID)
    
    rc = App.feViewRegenerate(0)
    GoTo Jumping_Out
    
Jumping_Out:
End Sub
