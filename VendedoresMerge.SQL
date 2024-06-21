USE [LOPEZ]
GO
/****** Object:  StoredProcedure [dbo].[VendedoresMerge]    Script Date: 21/06/2024 4:26:12 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Omar Gonzalez
-- ALTER date: 19-05-2014
-- Modiff date: 07/06/2017
-- Description:	Sincroniza la tabla VENDEDORES
-- =============================================
ALTER PROCEDURE [dbo].[VendedoresMerge]
	@LOG_ID			VARCHAR(20)
AS
BEGIN
DECLARE @Empresa VARCHAR(18);
DECLARE @ERROR VARCHAR(MAX);
SET @Empresa = (SELECT dbo.GetEmpresa());

BEGIN TRY
	--BEGIN TRAN;
		MERGE [dbo].[VENDEDORES] AS T
		USING [dbo].[VENDEDORES_ERP] AS S
		ON 
			(
				T.[EMPRESA_CODIGO] = S.[EMPRESA_CODIGO]
				AND T.[VENDEDOR_CODIGO] = S.[VENDEDOR_CODIGO]
			) 
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT
			(
				[EMPRESA_CODIGO],
				[VENDEDOR_CODIGO],
				[VENDEDOR_NOMBRE],
				[VENDEDOR_TIPO],
				[VENDEDOR_TELEFONO],
				[VENDEDOR_EMAIL],
				[VENDEDOR_DIRECCION],
				[VENDEDOR_CIUDAD],
				[VENDEDOR_PAIS],
				[VENDEDOR_REGION],
				[VENDEDOR_ESTADO],
				[UBICACION],
				[PROCESO],
				[FECHA_CREA],
				[CENTRO_OPERACION],
				[CEDULA],
				[f2181_id_caja],
				[f2181_id_cargue_fact],
				[f2181_id_tipo_docto_fact],
				[f2181_id_ubicacion_fact],
				[f150_id],
				[f2181_id_tipo_docto_pedido],
				[f2181_id_co_movto_fact],
				[f2181_id_co],
				[f2181_ind_factura],
				[f2181_id_tipo_docto_recibo]
			)
			VALUES
			(
				S.[EMPRESA_CODIGO],
				S.[VENDEDOR_CODIGO],
				S.[VENDEDOR_NOMBRE],
				S.[VENDEDOR_TIPO],
				S.[VENDEDOR_TELEFONO],
				S.[VENDEDOR_EMAIL],
				S.[VENDEDOR_DIRECCION],
				S.[VENDEDOR_CIUDAD],
				S.[VENDEDOR_PAIS],
				S.[VENDEDOR_REGION],
				S.[VENDEDOR_ESTADO],
				S.[UBICACION],
				'I',
				GETDATE(),
				S.[CENTRO_OPERACION],
				S.[CEDULA],
				S.[f2181_id_caja],
				S.[f2181_id_cargue_fact],
				S.[f2181_id_tipo_docto_fact],
				S.[f2181_id_ubicacion_fact],
				S.[f150_id],
				S.[f2181_id_tipo_docto_pedido],
				S.[f2181_id_co_movto_fact],
				S.[f2181_id_co],
				S.[f2181_ind_factura],
				S.[f2181_id_tipo_docto_recibo]
			)
		WHEN MATCHED AND 
						 (
							T.[VENDEDOR_CODIGO] <> S.[VENDEDOR_CODIGO]
							OR T.[VENDEDOR_NOMBRE] <> S.[VENDEDOR_NOMBRE]
							OR T.[VENDEDOR_TIPO] <> S.[VENDEDOR_TIPO]
							OR T.[VENDEDOR_TELEFONO] <> S.[VENDEDOR_TELEFONO]
							OR T.[VENDEDOR_EMAIL] <> S.[VENDEDOR_EMAIL]
							OR T.[VENDEDOR_DIRECCION] <> S.[VENDEDOR_DIRECCION]
							OR T.[VENDEDOR_CIUDAD] <> S.[VENDEDOR_CIUDAD]
							OR T.[VENDEDOR_PAIS] <> S.[VENDEDOR_PAIS]
							OR T.[VENDEDOR_REGION] <> S.[VENDEDOR_REGION]
							OR T.[VENDEDOR_ESTADO] <> S.[VENDEDOR_ESTADO]
							OR T.[UBICACION] <> S.[UBICACION]
							OR T.[CENTRO_OPERACION] <> S.[CENTRO_OPERACION]
							OR T.[CEDULA] <> S.[CEDULA]
							OR T.[f2181_id_caja] <> S.[f2181_id_caja]
							OR T.[f2181_id_cargue_fact] <> S.[f2181_id_cargue_fact]
							OR T.[f2181_id_tipo_docto_fact] <> S.[f2181_id_tipo_docto_fact]
							OR T.[f2181_id_ubicacion_fact] <> S.[f2181_id_ubicacion_fact]
							OR T.[f150_id] <> S.[f150_id]
							OR T.[f2181_id_tipo_docto_pedido] <> S.[f2181_id_tipo_docto_pedido]
							OR T.[f2181_id_co_movto_fact] <> S.[f2181_id_co_movto_fact]
							OR T.[f2181_id_co] <> S.[f2181_id_co]
							OR T.[f2181_ind_factura] <> S.[f2181_ind_factura]
							OR T.[f2181_id_tipo_docto_recibo] <>S.[f2181_id_tipo_docto_recibo]
						 ) THEN 
			UPDATE SET 
				T.[VENDEDOR_NOMBRE] = S.[VENDEDOR_NOMBRE],
				T.[VENDEDOR_TIPO] = S.[VENDEDOR_TIPO],
				T.[VENDEDOR_TELEFONO] = S.[VENDEDOR_TELEFONO],
				T.[VENDEDOR_EMAIL] = S.[VENDEDOR_EMAIL],
				T.[VENDEDOR_DIRECCION] = S.[VENDEDOR_DIRECCION],
				T.[VENDEDOR_CIUDAD] = S.[VENDEDOR_CIUDAD],
				T.[VENDEDOR_PAIS] = S.[VENDEDOR_PAIS],
				T.[VENDEDOR_REGION] = S.[VENDEDOR_REGION],
				T.[VENDEDOR_ESTADO] = S.[VENDEDOR_ESTADO],
				T.[UBICACION] = S.[UBICACION],
				T.[PROCESO] = 'U',
				T.[FECHA_MODIFICA] = GETDATE(),
				T.[CENTRO_OPERACION] = S.[CENTRO_OPERACION],
				T.[CEDULA] = S.[CEDULA],
				T.[f2181_id_caja] = S.[f2181_id_caja],
				T.[f2181_id_cargue_fact] = S.[f2181_id_cargue_fact],
				T.[f2181_id_tipo_docto_fact] = S.[f2181_id_tipo_docto_fact],
				T.[f2181_id_ubicacion_fact] = S.[f2181_id_ubicacion_fact],
				T.[f150_id] = S.[f150_id],
				T.[f2181_id_tipo_docto_pedido] = S.[f2181_id_tipo_docto_pedido],
				T.[f2181_id_co_movto_fact] = S.[f2181_id_co_movto_fact],
				T.[f2181_id_co] = S.[f2181_id_co],
				T.[f2181_ind_factura] = S.[f2181_ind_factura],
				T.[f2181_id_tipo_docto_recibo] = S.[f2181_id_tipo_docto_recibo]
		WHEN NOT MATCHED BY SOURCE  AND T.[VENDEDOR_ESTADO] = 'Y' THEN 
			UPDATE SET 
				T.[VENDEDOR_ESTADO] = 'N',
				T.[PROCESO] = 'U',
				T.[FECHA_MODIFICA] = GETDATE();		
		--OUTPUT $action, inserted.*, deleted.*;
	--COMMIT TRAN;

	MERGE [dbo].[PARAMETROS_SIIGO] AS T
		USING [dbo].[VENDEDORES_ERP] AS S
		ON 
			(
				T.[VENDEDOR_CODIGO] = S.[VENDEDOR_CODIGO]
			) 
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT
			(
				[VENDEDOR_CODIGO],
				[TIPO_Z],
				[BODEGA_VENDEDOR],
				[BODEGA_UBICACION],
				[CCOSTO_VENDEDOR],
				[SCCOSTO_VENDEDOR],
				[TIPO_DOCUMENTO],
				[NUMERO_DOCUMENTO],
				[CC_DEBITO],
				[CC_CREDITO]
			)
			VALUES
			(
				S.[VENDEDOR_CODIGO],
				'001',
				'0001',
				'000',
				'0001',
				'000',
				'R',
				1,
				'0000000000',
				'0000000000'
			);		

END TRY
BEGIN CATCH
	SET @ERROR = (SELECT '[' + CAST(ERROR_NUMBER() AS VARCHAR) + '] - ' + ERROR_MESSAGE() + ' {VendedoresMerge}');
	--UPDATE [dbo].[RSALES_SYNC_LOG] SET [LOG_DATE_END] = GETDATE(), [LOG_STAT] = 'FAILURE', [LOG_ERROR] = @ERROR WHERE [LOG_ID] = @LOG_ID;
	RAISERROR (@ERROR, 16, 1 );
END CATCH

END
