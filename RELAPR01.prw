#Include 'Protheus.ch'
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³NfeDocVin ³ Autor ³Vitor Henrique         ³ Data ³14.08.2023	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio simples de uma seção					            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function RELAPR01()
	Local oReport := nil
	Local cPerg:= Padr("RELAPR01",10)
	
	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	Pergunte(cPerg,.F.)	          
		
	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return

Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	Local oBreak
	Local oFunction
	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"SALDO OBSOLETO",cNome,{|oReport| ReportPrint(oReport)})
	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport, "Produtos", {"SB1"}, NIL, .F., .T.)
	TRCell():New(oSection1,"B1_COD"   	,"TRB","Codigo"		,"@!",30)
	TRCell():New(oSection1,"B1_DESC"  	,"TRB","Descrição"	,"@!",90)
	TRCell():New(oSection1,"B1_UM"   	,"TRB","Unidade"	,"@!",20)	
    TRCell():New(oSection1,"D1_DATA"   , "TRB", "DT.Ult.Compra","@!",20)
    TRCell():New(oSection1,"B2_QATU"  	,"TRB","Saldo Atual" ,"@!",20,,,"RIGHT")
    TRCell():New(oSection1,"D2_DATA"   , "TRB", "DT.Ult.Venda","@!",20)	

	TRFunction():New(oSection1:Cell("B1_COD"),NIL,"COUNT",,,,,.F.,.T.)
	
	oReport:SetTotalInLine(.F.)
       
    //Aqui, farei uma quebra  por seção
	//oSection1:SetPageBreak(.T.)		
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""		
	Local cNcm      := ""   
	Local lPrim 	:= .T.	      

    // Montando a Query do relatorio
    cQuery := " SELECT B1_COD, B1_DESC, B1_UM, B2_QATU, "
    cQuery += " (
    cQuery += " SELECT MAX(D1_EMISSAO) "
    cQuery += " FROM " +RETSQLNAME("SD1")+ " SD1 "
    cQuery += " WHERE D1_COD=B1_COD AND D1_FILIAL=B1_FILIAL "
    cQuery += " AND SD1.D_E_L_E_T_= ' ' "
    cQuery += " )D1_EMISSAO, "
    cQuery += " (
    cQuery += " SELECT MAX(D2_EMISSAO) "
    cQuery += " FROM " +RETSQLNAME("SD2")+ " SD2 "
    cQuery += " WHERE D2_COD=B2_COD AND D2_FILIAL=B1_FILIAL "
    cQuery += " AND SD2.D_E_L_E_T_= ' ' "
    cQuery += " )D2_EMISSAO "
    cQuery += " FROM " +RETSQLNAME("SB1")+ " SB1 "
    cQuery += " LEFT JOIN " +RETSQLNAME("SB2")+ " SB2 ON SB2.D_E_L_E_T_=''  "
    cQuery += " AND B2_FILIAL='" +xfilial("SB2") + "' "
    cQuery += " AND B2_COD=B1_COD "
    cQuery += " WHERE SB1.D_E_L_E_T_= ' ' "
    cQuery += " AND B1_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
    cQuery += " AND B1_TIPO BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
    cQuery += " AND B1_FILIAL='" +xfilial("SB1") + "' "
	cQuery += " ORDER BY B1_COD "
	
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRB") <> 0
		DbSelectArea("TRB")
		DbCloseArea()
	ENDIF
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRB"	
	
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	
	oReport:SetMeter(TRB->(LastRec()))	

    oSection1:Init()

	//Irei percorrer todos os meus registros
	While !Eof()
		
		If oReport:Cancel()
			Exit
		EndIf
	
		//inicializo a primeira seção
					
		oReport:IncMeter()		
		IncProc("Imprimindo produto "+alltrim(TRB->B1_COD))
		cCOD 	:= TRB->B1_COD
		
		oSection1:Cell("B1_COD"):SetValue(TRB->B1_COD)
		oSection1:Cell("B1_DESC"):SetValue(TRB->B1_DESC)				
		oSection1:Cell("B1_UM"):SetValue(TRB->B1_UM)			
		oSection1:Cell("D1_DATA"):SetValue(DTOC(STOD(TRB->D1_EMISSAO)))
		oSection1:Cell("B2_QATU"):SetValue(Transform(TRB->B2_QATU,"@E 999.9999"))		//Transform(QRY->VALOR,"@E 99,999,999.99"))
		oSection1:Cell("D2_DATA"):SetValue(DTOC(STOD(TRB->D2_EMISSAO)))		
		oSection1:Printline()

 		//finalizo a primeira seção
 		TRB->(dbSkip())
	Enddo
		oSection1:Finish()
Return

