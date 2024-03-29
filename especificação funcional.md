# abap_first_alv: <br> Relatório Controle de Pedidos e Remessas Filiais

## Objetivo
O objetivo da demanda é criar um relatório ALV onde as Filiais possam consultar Ordens de Vendas e Remessas criadas, com a data prevista para saída da remessa. Esse relatório é a nível de item (Número de Série), e deve conter os seguintes campos:


### Tela de Seleção
- Organização de Vendas
- Data de Criação da Ordem

### Tela de Resultado
- Ordem de Venda
- Tipo de Documento 
- Tipo de Documento - Descrição
- Motivo da Ordem - Descrição
- Recebedor da Mercadoria (Número BP)
- Recebedor da Mercadoria (Nome)
- Referência de Cliente
<!-- - Nome do Médico
- Data de Cirurgia -->
- Data de Envio
- Remessa
- Material
- Número de Série

## Estratégia do Desenvolvimento (Selects & Relações entre as Tabelas)

### Tela de Seleção:

- Organização de Vendas
VBAK-VKORG
- Data de Criação da Ordem
VBAK-ERDAT

### Tela de Resultado:

- Organização de Vendas
VBAK-VKORG

- Ordem de Venda
VBAP-VBELN

- Tipo de Documento 
Com VBAP-VBELN = VBAK-VBELN, buscar VBAK-AUART 
Com VBAK-AUART = TVAKT-AUART, selecionar TVAKT-BEZEI

- Motivo da Ordem 
Com VBAP-VBELN = VBAK-VBELN, buscar VBAK-AUGRU 
Com VBAK-AUGRU = TVAU-AUGRU, selecionar TVAU- BEZEI

- Cliente (Número BP)
Com VBAP-VBELN = VBPA-VBELN e VBPA-PARVW=RM, selecionar VBPA-KUNNR

- Recebedor da Mercadoria (Nome)
Com KNA1-KUNNR = VBPA-KUNNR, selecionar KNA1-NAME1
	
- Nome do Médico
Com VBAP-VBELN = VBPA-VBELN e VBPA-PARVW=MD, selecionar VBPA-KUNNR
Com KNA1-KUNNR = VBPA-KUNNR, selecionar KNA1-NAME1

- Se VBPA-KUNNR = Null
Selecionar VBAK-BNAME

- Referência de Cliente com
VBAK-BSTNK

<!--
- Data de Envio
VBAK-BSTDK
-->

- Material
VBAP-MATNR

- Remessa
Com VBAP-VBELN = VBFA-VBELV, selecionar VBFA-VBELN

- Número de Série
Com VBFA-VBELN = SER01-LIEF_NR, buscar SER01-OBKNR
	Com OBJK- OBKNR = SER01-OBKNR e OBJK-MATNR = VBAP-MATNR, selecionar OBJK-SERNR

## Extra
 - Todos os campos devem possuir tradução para Português, Inglês e Espanhol, de acordo com o login do usuário.
 - HOTSPOT: Ao clicar nos dados das colunas Ordem de Venda, Recebedor da Mercadoria e Remessa. O relatório deve ser redirecionado para a transação de gerenciamento que corresponde a cada campo. VA03 Ordem de Venda, BP Recebedor da Mercadoria e VL03 Remessa. Direto para a tela de detalhes do item clicado.

 #### by Argel Capela


