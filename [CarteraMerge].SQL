USE [LOPEZ]
GO
/****** Object:  StoredProcedure [dbo].[CarteraMerge]    Script Date: 21/06/2024 5:06:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Omar Gonzalez
-- ALTER date: 26-05-2014
-- Description:	Sincroniza la tabla CARTERA
-- =============================================
ALTER PROCEDURE [dbo].[CarteraMerge]
	@LOG_ID			VARCHAR(20)
AS
BEGIN
DECLARE @Empresa1 VARCHAR(18);
DECLARE @ERROR VARCHAR(MAX);
SET @Empresa1 = (SELECT dbo.GetEmpresa());
DECLARE @RESUMEN_CARTERA VARCHAR(1);
SET @RESUMEN_CARTERA = (SELECT RESUMEN_CARTERA FROM CONFIGURACION);
BEGIN TRY

	--BEGIN TRAN;
		MERGE [dbo].[CARTERA] AS T
		USING [dbo].[CARTERA_ERP] AS S
		ON 
			(
				T.[EMPRESA_CODIGO] = S.[EMPRESA_CODIGO]
				AND T.[CLIENTE_CODIGO] = S.[CLIENTE_CODIGO]
				AND T.[NUMERO_DOCUMENTO] = S.[NUMERO_DOCUMENTO]
				AND T.[TIPO_DOCUMENTO] = S.[TIPO_DOCUMENTO]
				AND T.[VENDEDOR_CODIGO] = S.[VENDEDOR_CODIGO]
			) 
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT
			(
				[EMPRESA_CODIGO],
				[CLIENTE_CODIGO],
				[VENDEDOR_CODIGO],
				[COBRADOR_CODIGO],
				[TIPO_DOCUMENTO],
				[NUMERO_DOCUMENTO],
				[FECHA_DOCUMENTO],
				[FECHA_VENCIMIENTO],
				[SALDO],
				[OBSERVACIONES],
				[BASE_RETENCION],
				[VALOR_IMPUESTOS],
				[SALDO_BASE],
				[ESTADO],
				[PROCESO],
				[FECHA_CREA],
				CENTRO_OPERACION,
				CUOTA,
				SUCURSAL
			)
			VALUES
			(
				S.[EMPRESA_CODIGO],
				S.[CLIENTE_CODIGO],
				S.[VENDEDOR_CODIGO],
				S.[COBRADOR_CODIGO],
				S.[TIPO_DOCUMENTO],
				S.[NUMERO_DOCUMENTO],
				S.[FECHA_DOCUMENTO],
				S.[FECHA_VENCIMIENTO],
				S.[SALDO],
				S.[OBSERVACIONES],
				S.[BASE_RETENCION],
				S.[VALOR_IMPUESTOS],
				S.[SALDO_BASE],
				'Y',
				'I',
				GETDATE(),
				S.CENTRO_OPERACION,
				S.CUOTA,
				S.SUCURSAL
			)
		WHEN MATCHED AND 
							(								
								T.[COBRADOR_CODIGO] <> S.[COBRADOR_CODIGO]
								OR T.[FECHA_DOCUMENTO] <> S.[FECHA_DOCUMENTO]
								OR T.[FECHA_VENCIMIENTO] <> S.[FECHA_VENCIMIENTO]
								OR T.[SALDO] <> S.[SALDO]
								OR T.[OBSERVACIONES] <> S.[OBSERVACIONES]
								OR T.[BASE_RETENCION] <> S.[BASE_RETENCION]
								OR T.[VALOR_IMPUESTOS] <> S.[VALOR_IMPUESTOS]
								OR T.[SALDO_BASE] <> S.[SALDO_BASE]
								OR T.[ESTADO] <> S.[ESTADO]	
								OR T.CENTRO_OPERACION <> S.CENTRO_OPERACION
								OR T.CUOTA <> S.CUOTA
								OR T.SUCURSAL <> S.SUCURSAL
							) THEN 
			UPDATE SET 
				T.[COBRADOR_CODIGO] = S.[COBRADOR_CODIGO],
				T.[FECHA_DOCUMENTO] = S.[FECHA_DOCUMENTO],
				T.[FECHA_VENCIMIENTO] = S.[FECHA_VENCIMIENTO],
				T.[SALDO] = S.[SALDO],
				T.[OBSERVACIONES] = S.[OBSERVACIONES],
				T.[BASE_RETENCION] = S.[BASE_RETENCION],
				T.[VALOR_IMPUESTOS] = S.[VALOR_IMPUESTOS],
				T.[SALDO_BASE] = S.[SALDO_BASE],
				--T.[ESTADO] = 'Y',
				T.[PROCESO] = 'U',
				T.[FECHA_MODIFICA] = GETDATE(),
				T.[ESTADO] = S.[ESTADO],
				T.CENTRO_OPERACION = S.CENTRO_OPERACION,
				T.CUOTA = S.CUOTA,
				T.SUCURSAL = S.SUCURSAL
		WHEN NOT MATCHED BY SOURCE  AND T.[ESTADO] = 'Y' THEN 
			UPDATE SET 
				T.[ESTADO] = 'N',
				T.[PROCESO] = 'U',
				T.[FECHA_MODIFICA] = GETDATE();		
		--OUTPUT $action, inserted.*, deleted.*;
	--COMMIT TRAN;

IF (@RESUMEN_CARTERA = 'Y')
BEGIN
	DELETE FROM MENSAJE_CLIENTE WHERE TIPO = 'RESUMEN_CARTERA'
	DECLARE @EMPRESA_CODIGO  VARCHAR(18), @VENDEDOR_CODIGO  VARCHAR(18), @CLIENTE_CODIGO  VARCHAR(18);
	DECLARE CCLIENTES CURSOR FOR SELECT DISTINCT
		C.EMPRESA_CODIGO, 
		C.VENDEDOR_CODIGO, 
		C.CLIENTE_CODIGO
	FROM 
		VENDEDORES V INNER JOIN CARTERA C ON
			V.EMPRESA_CODIGO = C.EMPRESA_CODIGO
			AND C.VENDEDOR_CODIGO = V.VENDEDOR_CODIGO 
		INNER JOIN CLIENTES CC ON
			CC.EMPRESA_CODIGO = C.EMPRESA_CODIGO
			AND CC.CLIENTE_CODIGO = C.CLIENTE_CODIGO
		INNER JOIN RUTAS R ON
			R.EMPRESA_CODIGO = C.EMPRESA_CODIGO
			AND R.VENDEDOR_CODIGO = C.VENDEDOR_CODIGO
			AND V.VENDEDOR_CODIGO = C.VENDEDOR_CODIGO
			AND R.CLIENTE_CODIGO = C.CLIENTE_CODIGO
	WHERE
		V.VENDEDOR_ESTADO = 'Y'
		AND C.ESTADO = 'Y'
		AND CC.CLIENTE_ESTADO = 'Y'
		AND R.ESTADO  = 'Y';

	OPEN CCLIENTES 
	FETCH CCLIENTES INTO @EMPRESA_CODIGO, @VENDEDOR_CODIGO, @CLIENTE_CODIGO;
	WHILE (@@FETCH_STATUS = 0 )
	BEGIN
		BEGIN TRY	
			DECLARE @EMPRESA  VARCHAR(18), 
					@VENDEDOR  VARCHAR(18), 
					@CLIENTE  VARCHAR(18), 
					@TIPO_DOCUMENTO  VARCHAR(50),
					@NUMERO_DOCUMENTO  VARCHAR(20),
					@FECHA_VENCIMIENTO DATETIME,
					@SALDO DECIMAL(18,2),
					@VENCIDAS  VARCHAR(2),
					@DIAS_VENCIDOS  INT;

			DECLARE CDOCUMENTOS CURSOR FOR SELECT 
				C.EMPRESA_CODIGO, 
				C.VENDEDOR_CODIGO, 
				C.CLIENTE_CODIGO, 	
				C.TIPO_DOCUMENTO,
				C.NUMERO_DOCUMENTO,
				C.FECHA_VENCIMIENTO,
				C.SALDO,
				CASE WHEN C.FECHA_VENCIMIENTO < GETDATE() THEN 'SI' ELSE 'NO' END AS VECIDA,
				DATEDIFF(DAY, C.FECHA_VENCIMIENTO, GETDATE()) AS DIAS_VENDIDOS
			FROM 
				VENDEDORES V INNER JOIN CARTERA C ON
					V.EMPRESA_CODIGO = C.EMPRESA_CODIGO
					AND C.VENDEDOR_CODIGO = V.VENDEDOR_CODIGO 
				INNER JOIN CLIENTES CC ON
					CC.EMPRESA_CODIGO = C.EMPRESA_CODIGO
					AND CC.CLIENTE_CODIGO = C.CLIENTE_CODIGO
				INNER JOIN RUTAS R ON
					R.EMPRESA_CODIGO = C.EMPRESA_CODIGO
					AND R.VENDEDOR_CODIGO = C.VENDEDOR_CODIGO
					AND V.VENDEDOR_CODIGO = C.VENDEDOR_CODIGO
					AND R.CLIENTE_CODIGO = C.CLIENTE_CODIGO
			WHERE
				V.VENDEDOR_ESTADO = 'Y'
				AND C.ESTADO = 'Y'
				AND CC.CLIENTE_ESTADO = 'Y'
				AND R.ESTADO  = 'Y'
				AND C.EMPRESA_CODIGO = @EMPRESA_CODIGO
				AND C.VENDEDOR_CODIGO = @VENDEDOR_CODIGO
				AND C.CLIENTE_CODIGO = @CLIENTE_CODIGO;

			OPEN CDOCUMENTOS
			FETCH CDOCUMENTOS INTO @EMPRESA, @VENDEDOR, @CLIENTE, @TIPO_DOCUMENTO, @NUMERO_DOCUMENTO,	@FECHA_VENCIMIENTO, @SALDO,	@VENCIDAS, @DIAS_VENCIDOS;
			DECLARE @MENSAJE VARCHAR(MAX);
			SET @MENSAJE = '';
			WHILE (@@FETCH_STATUS = 0 )
			BEGIN
				BEGIN TRY
					SET @MENSAJE = @MENSAJE + '<TR><TD>' + @TIPO_DOCUMENTO + @NUMERO_DOCUMENTO + '</TD><TD align=right>' + FORMAT(@SALDO, 'C', 'es-co')  + '</TD><TD>' + SUBSTRING(CONVERT(VARCHAR, @FECHA_VENCIMIENTO, 126), 1, 10) + '</TD><TD align=right>' + CAST(@DIAS_VENCIDOS AS VARCHAR(10)) + '</TD></TR>';
				
				END TRY
				BEGIN CATCH		
					DECLARE  @ERROR4 VARCHAR(MAX);
					SET @ERROR4 = (SELECT '[' + CAST(ERROR_NUMBER() AS VARCHAR) + '] - ' + ERROR_MESSAGE());	
				END CATCH	
				FETCH CDOCUMENTOS INTO @EMPRESA, @VENDEDOR, @CLIENTE, @TIPO_DOCUMENTO, @NUMERO_DOCUMENTO,	@FECHA_VENCIMIENTO, @SALDO,	@VENCIDAS, @DIAS_VENCIDOS;
			END		
			CLOSE CDOCUMENTOS
			DEALLOCATE CDOCUMENTOS
			--SELECT 'Resumen de Cartera<BR><BR><TABLE BORDER=1 CELLSPACING=0><TR><TD align=center>Documento</TD><TD align=center>Saldo</TD><TD align=center>F. Ven</TD><TD align=center>Dias Ven</TD></TR>' + @MENSAJE + '</TABLE>'
			INSERT INTO [dbo].[MENSAJE_CLIENTE]
			(
				[EMPRESA_CODIGO],
				[VENDEDOR_CODIGO],
				[CLIENTE_CODIGO],
				[FECHA_ACTUALIZACION],
				[MENSAJE],
				[PROCESO],
				[FECHA_CREA],
				[FECHA_MODIFICA],
				[TIPO]
			)
			VALUES
			(
				@EMPRESA,
				@VENDEDOR,
				@CLIENTE,
				GETDATE(),
				'Resumen de Cartera<BR><BR><font size=2><TABLE BORDER=1 CELLSPACING=0><TR><TD align=center>Documento</TD><TD align=center>Saldo</TD><TD align=center>F. Ven</TD><TD align=center>Dias Ven</TD></TR>' + @MENSAJE + '</TABLE></font>',
				'I',
				GETDATE(),
				NULL,
				'RESUMEN_CARTERA'
			);

		END TRY
		BEGIN CATCH		
			DECLARE  @ERROR5 VARCHAR(MAX);
			SET @ERROR5 = (SELECT '[' + CAST(ERROR_NUMBER() AS VARCHAR) + '] - ' + ERROR_MESSAGE());	
		END CATCH	
		FETCH CCLIENTES INTO @EMPRESA_CODIGO, @VENDEDOR_CODIGO, @CLIENTE_CODIGO;
	END
	CLOSE CCLIENTES
	DEALLOCATE CCLIENTES
END



END TRY
BEGIN CATCH
	
	SET @ERROR = (SELECT '[' + CAST(ERROR_NUMBER() AS VARCHAR) + '] - ' + ERROR_MESSAGE() + ' {CarteraMerge}');
	--UPDATE [dbo].[RSALES_SYNC_LOG] SET [LOG_DATE_END] = GETDATE(), [LOG_STAT] = 'FAILURE', [LOG_ERROR] = @ERROR WHERE [LOG_ID] = @LOG_ID;
	RAISERROR (@ERROR, 16, 1 );
END CATCH
END




