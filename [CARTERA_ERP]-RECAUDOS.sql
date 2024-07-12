USE [COMORIENTE]
GO

/****** Object:  View [dbo].[CARTERA_ERP]    Script Date: 12/07/2024 11:15:00 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[CARTERA_ERP]
AS
SELECT 
	'807004655' AS [EMPRESA_CODIGO]
	,CAST([CLIENTE_CODIGO] AS VARCHAR (18)) COLLATE Modern_Spanish_CI_AS AS [CLIENTE_CODIGO]
	,[VENDEDOR_CODIGO] COLLATE Modern_Spanish_CI_AS AS [VENDEDOR_CODIGO]
	,[COBRADOR_CODIGO] COLLATE Modern_Spanish_CI_AS AS [COBRADOR_CODIGO]
	,CAST([TIPO_DOCUMENTO] AS VARCHAR (50)) COLLATE Modern_Spanish_CI_AS AS [TIPO_DOCUMENTO]
	,CAST([NUMERO_DOCUMENTO] AS VARCHAR (20)) COLLATE Modern_Spanish_CI_AS AS [NUMERO_DOCUMENTO]
	,CAST([FECHA_DOCUMENTO] AS DATE) AS [FECHA_DOCUMENTO]
	,CAST([FECHA_VENCIMIENTO] AS DATE) AS [FECHA_VENCIMIENTO]
	,CAST([SALDO] AS DECIMAL(18,2)) [SALDO]
	,CAST([OBSERVACIONES] AS VARCHAR (500)) COLLATE Modern_Spanish_CI_AS AS [OBSERVACIONES]
	,CAST([BASE_RETENCION] AS DECIMAL(18,2)) AS [BASE_RETENCION]
	,CAST([VALOR_IMPUESTOS] AS DECIMAL(18,2)) AS [VALOR_IMPUESTOS]
	,CAST([SALDO_BASE] AS DECIMAL(18,2)) AS [SALDO_BASE]
	,CAST([CUENTA_CONTABLE] AS VARCHAR (20)) COLLATE Modern_Spanish_CI_AS AS [CUENTA_CONTABLE]
	,[ESTADO] COLLATE Modern_Spanish_CI_AS AS [ESTADO]
	,DOCUMENTO
	,CONVERT(VARCHAR (10),CENTRO_OPERACION) COLLATE Modern_Spanish_CI_AS as CENTRO_OPERACION
	,CONVERT(INT,CUOTA) AS CUOTA
	,CAST(SUCURSAL AS VARCHAR (10)) COLLATE Modern_Spanish_CI_AS [F353_ID_SUCURSAL]
	,CAST(F353_ID_UN_CRUCE AS VARCHAR (10)) COLLATE Modern_Spanish_CI_AS F353_ID_UN_CRUCE
	
FROM   
OPENQUERY ([SIESA-M1-SQLSW-DB13.CBM3OHOGEAJR.US-EAST-1.RDS.AMAZONAWS.COM],'
SELECT DISTINCT
	RTRIM(T.f200_id) + ''-'' + RTRIM(C.f201_id_sucursal) [CLIENTE_CODIGO],
	ISNULL(RTRIM(C.f201_id_vendedor), ''-'') [VENDEDOR_CODIGO],
	ISNULL(ISNULL(RTRIM(C.f201_id_cobrador),  rTRIM(C.f201_id_vendedor)), ''-'')  [COBRADOR_CODIGO],
	RTRIM(CDC.F350_ID_TIPO_DOCTO) [TIPO_DOCUMENTO],
	RTRIM(CDC.F350_ID_TIPO_DOCTO) + ''-'' + CONVERT(VARCHAR, CDC.F350_CONSEC_DOCTO)  NUMERO_DOCUMENTO,

	CSA.f353_fecha [FECHA_DOCUMENTO],
	CSA.f353_fecha_vcto [FECHA_VENCIMIENTO],
	isnull(SUM(CSA.f353_total_db) - SUM(CSA.f353_total_cr) + SUM(CSA.f353_total_ch_postf),0) [SALDO],
	''<B>INFORMACIÓN DE FACTURA</B> 
	<BR></BR>
	<BR><B>Subtotal: </B>''+FORMAT(isnull(SUM(CSA.f353_valor_base), 0), ''C'', ''es-co'')+''</BR>	
	<BR><B>VALOR IMPUESTOS: </B>''+FORMAT(isnull(SUM(CSA.f353_valor_impuesto), 0), ''C'', ''es-co'')+''</BR>
	<BR><B>TOTAL FACTURA: </B>'' +FORMAT(isnull(SUM(CSA.f353_total_db), 0), ''C'', ''es-co'')+''</BR>'' AS [OBSERVACIONES],
	isnull(SUM(CSA.f353_valor_base),0) [BASE_RETENCION],
	isnull(SUM(CSA.f353_valor_impuesto),0) [VALOR_IMPUESTOS],
	isnull(SUM(CSA.f353_total_db), 0) [SALDO_BASE],
	LEFT(CAST (CONVERT (VARCHAR(8), [F353_FECHA_DSCTO_PP], 112) AS VARCHAR (MAX)), 8)[CUENTA_CONTABLE],
	''Y'' [ESTADO],
	RTRIM(CDC.F350_ID_TIPO_DOCTO) + ''-'' + CONVERT(VARCHAR, CDC.F350_CONSEC_DOCTO) DOCUMENTO,
	RTRIM(CSA.[f353_id_co_cruce]) CENTRO_OPERACION,
	[f353_nro_cuota_cruce] CUOTA	,
	F353_ID_SUCURSAL SUCURSAL,
	F353_ID_UN_CRUCE	
from 
	[UnoEE_Comoriente_Real].[dbo].T350_CO_DOCTO_CONTABLE CDC INNER JOIN [UnoEE_Comoriente_Real].dbo.T351_CO_MOV_DOCTO CMD ON
		CDC.f350_id_cia = CMD.f351_id_cia
		AND CMD.F351_ROWID_DOCTO = CDC.F350_ROWID
		AND CMD.f351_rowid_tercero = CDC.f350_rowid_tercero
	INNER JOIN [UnoEE_Comoriente_Real].[dbo].T353_CO_SALDO_ABIERTO CSA ON
		CMD.f351_id_cia = CSA.f353_id_cia
		AND CMD.F351_ROWID = CSA.F353_ROWID_MOV_DOCTO
		AND CMD.f351_rowid_tercero = CSA.f353_rowid_tercero
		AND CMD.f351_id_sucursal = CSA.f353_id_sucursal
	INNER JOIN [UnoEE_Comoriente_Real].[dbo].t201_mm_clientes C ON
		CSA.f353_id_cia = C.f201_id_cia
		AND CSA.f353_rowid_tercero = C.f201_rowid_tercero
		AND CSA.f353_id_sucursal = C.f201_id_sucursal
	INNER JOIN [UnoEE_Comoriente_Real].[dbo].t200_mm_terceros T ON
		T.f200_id_cia = C.f201_id_cia 
		AND T.f200_rowid = C.f201_rowid_tercero
WHERE
	CDC.f350_id_cia = 1
	AND (CSA.f353_total_db - CSA.f353_total_cr) <> 0
	AND RTRIM(CDC.F350_ID_TIPO_DOCTO) IN (''FEV'', ''FVS'', ''FEC'',''FV1'',''NC1'',''NCE'',''NCS'',''NDE'')
GROUP BY
	RTRIM(T.f200_id) + ''-'' + RTRIM(C.f201_id_sucursal),
	RTRIM(C.f201_id_vendedor),
	RTRIM(C.f201_id_cobrador),
	--R.VENDEDOR_CODIGO,--
	RTRIM(CDC.F350_ID_TIPO_DOCTO),
	RTRIM(CDC.F350_ID_TIPO_DOCTO) + ''-'' + CONVERT(VARCHAR, CDC.F350_CONSEC_DOCTO),
	CSA.f353_fecha,
	CSA.f353_fecha_vcto,
	LEFT(CAST (CONVERT (VARCHAR(8), [F353_FECHA_DSCTO_PP], 112) AS VARCHAR (MAX)), 8),
	RTRIM(CDC.F350_ID_TIPO_DOCTO) + ''-'' + CONVERT(VARCHAR, CDC.F350_CONSEC_DOCTO),
	RTRIM(CSA.[f353_id_co_cruce]) ,
	[f353_nro_cuota_cruce] 	,
	F353_ID_SUCURSAL,
	F353_ID_UN_CRUCE 

UNION ALL
SELECT  DISTINCT
			RTRIM(T.f200_nit) + ''-'' + RTRIM(C.f201_id_sucursal) [CLIENTE_CODIGO],
			ISNULL(RTRIM(C.f201_id_vendedor), ''-'') [VENDEDOR_CODIGO],
			ISNULL(ISNULL(RTRIM(C.f201_id_cobrador), RTRIM(C.f201_id_vendedor)), ''-'')	[COBRADOR_CODIGO],
			RTRIM(CSA.f353_id_tipo_docto_cruce) [TIPO_DOCUMENTO],
			RTRIM(CSA.f353_id_tipo_docto_cruce) + ''-'' + CONVERT(VARCHAR, CSA.f353_consec_docto_cruce)+''-''+RTRIM(CSA.F353_id_co_cruce) NUMERO_DOCUMENTO,
			MIN(CSA.f353_fecha) [FECHA_DOCUMENTO],
			MIN(CSA.f353_fecha_vcto) [FECHA_VENCIMIENTO],
			isnull(SUM(CSA.f353_total_db) - SUM(CSA.f353_total_cr) + SUM(CSA.f353_total_ch_postf),0) [SALDO],
			''Total Factura: '' + FORMAT(isnull(SUM(CSA.f353_total_db), 0), ''C'', ''es-co'')+'' ''+RTRIM(CDC.F350_ID_TIPO_DOCTO) + ''-'' + CONVERT(VARCHAR, CDC.F350_CONSEC_DOCTO) [OBSERVACIONES],
			0 [BASE_RETENCION],
			0 [VALOR_IMPUESTOS],
			isnull(SUM(CSA.f353_total_db), 0) [SALDO_BASE],	
			'''' [CUENTA_CONTABLE],	
			''Y'' [ESTADO],
			RTRIM(CDC.F350_ID_TIPO_DOCTO) + ''-'' + CONVERT(VARCHAR, CDC.F350_CONSEC_DOCTO) DOCUMENTO,
			RTRIM(CSA.[f353_id_co_cruce]) CENTRO_OPERACION,
			CONVERT(INT,[f353_nro_cuota_cruce]) CUOTA	,
			F353_ID_SUCURSAL SUCURSAL,
			F353_ID_UN_CRUCE
		FROM 
			UnoEE_Comoriente_Real.dbo.t350_co_docto_contable CDC INNER JOIN UnoEE_Comoriente_Real.dbo.t353_co_saldo_abierto CSA ON 
				CDC.f350_rowid = CSA.f353_rowid_docto 
			INNER JOIN UnoEE_Comoriente_Real.dbo.t201_mm_clientes C ON
		CSA.f353_id_cia = C.f201_id_cia
			AND CSA.f353_rowid_tercero = C.f201_rowid_tercero
			AND CSA.f353_id_sucursal = C.f201_id_sucursal
		INNER JOIN UnoEE_Comoriente_Real.dbo.t200_mm_terceros T ON T.f200_id_cia = C.f201_id_cia 
			AND T.f200_rowid = C.f201_rowid_tercero
		INNER JOIN UnoEE_Comoriente_Real.dbo.T010_MM_COMPANIAS CM ON 
			CDC.f350_id_cia = CM.F010_ID													 
		WHERE 
			CDC.f350_id_cia = 1
			--AND f350_id_tipo_docto = ''FVS''  
			AND RTRIM(Csa.F353_ID_TIPO_DOCTO_cruce) IN (''FVS'') 
			--AND f353_id_tipo_docto_cruce IN (''F5'',''F6'',''F7'',''F11'',''F12'',''F13'',''F14'')
			AND  (CSA.f353_total_db - CSA.f353_total_cr) <> 0
    
		GROUP BY
			CAST(RTRIM(CM.F010_NIT) AS VARCHAR(18)),
			RTRIM(T.f200_nit) + ''-'' + RTRIM(C.f201_id_sucursal),
			RTRIM(C.f201_id_vendedor),
			RTRIM(C.f201_id_cobrador),
			RTRIM(CDC.F350_ID_TIPO_DOCTO),
			RTRIM(CDC.F350_ID_TIPO_DOCTO) + ''-'' + CONVERT(VARCHAR, CDC.F350_CONSEC_DOCTO),
			CDC.f350_consec_docto,
			RTRIM(CSA.f353_id_tipo_docto_cruce)+ ''-'' +CONVERT(VARCHAR, CSA.f353_consec_docto_cruce)+''-''+RTRIM(CSA.F353_id_co_cruce),
			CSA.f353_id_tipo_docto_cruce,CSA.f353_consec_docto_cruce,CSA.[f353_id_co_cruce],
			CDC.f350_id_co,
			[f353_nro_cuota_cruce],
			F353_ID_SUCURSAL,
			F353_ID_UN_CRUCE 	
	
	
	')












GO
