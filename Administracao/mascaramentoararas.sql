spool /rman/refresh/dbhom01/scripts_mascaramento_dbhom01.log

alter session set current_schema=prod_dba;

update itm_tip_prm i
   set i.itpr_val = '3141'
 where i.itpr_tipp_cod = 58;

update itm_tip_prm i
   set i.itpr_val = 'cartaocmt'
 where i.itpr_tipp_cod = 59;

update itm_tip_prm i
   set i.itpr_val = 'http://webservices.apb.com.br/wswholesale/ws_users.asmx'
 where i.itpr_tipp_cod = 60;

update itm_tip_prm i
   set i.itpr_val = 'http://webservices.apb.com.br/wswholesale/ws_orders.asmx'
 where i.itpr_tipp_cod = 61;

update itm_tip_prm i
   set i.itpr_val = '\\HEISENBERG301\ORACLEIO\CHEQUINHO\'
 where i.itpr_tipp_cod = 76;

update itm_tip_prm i
   set i.itpr_val = 'n@sodexhopass.com.br'
 where i.itpr_tipp_cod = 102;

insert into tip_prm
  values(110, 'OCR PROCESSO DE CONFIRMAÇÃO DE PGTO(Pré)',2,'G');

insert into itm_tip_prm
values(110, '27/apr/2010',null,'28/apr/2010',user,null,null,'mauro.koura@sodexhopass.com.br;goncalo.araujo@sodexhopass.com.br;luciano.carvalho@sodexhopass.com.br');

update itm_tip_prm i
   set i.itpr_val = 'n@sodexhopass.com.br;n@sodexhopass.com.br;n@sodexhopass.com.br'
 where i.itpr_tipp_cod = 110;

update itm_tip_prm i
   set i.itpr_val = '\\heisenberg301\Homolog_Heisenberg'
 where i.itpr_tipp_cod = 111;

update itm_tip_prm i
   set i.itpr_val = 'GAUSS103'
 where i.itpr_tipp_cod = 112;

update itm_tip_prm i
   set i.itpr_val = '\\heisenberg301\producao\Fontes\dos2unix\UNIX2DOS.EXE' -- em produção é \\SPBAPPL01\producao\Fontes\dos2unix\UNIX2DOS.EXE
 where i.itpr_tipp_cod = 113;                                              -- essa pasta e programa não existem no Heisenberg, precisa criar e copiar o programa


update prod_dba.itm_tip_prm
set    itpr_val = 'http://homolog-araras.sodexhopass.com.br:7778/reports/rwservlet?server=rep_araras_homo'
where  itpr_tipp_cod = 71;

update prod_dba.itm_tip_prm
set    itpr_val = '\\heisenberg301\oracleio\'
where  itpr_tipp_cod = 73;

UPDATE ITM_TIP_PRM I 
   SET I.ITPR_VAL      = '200.185.139.210'
 WHERE I.ITPR_TIPP_COD = 72;

update prod_dba.itm_tip_prm
set    itpr_val = '\\heisenberg301\oracleio\faturamento\hawb\'
where  itpr_tipp_cod = 79;

update prod_dba.itm_tip_prm
set    itpr_val = '\\heisenberg301\oracleio\common\relatorios\'
where  itpr_tipp_cod = 84;

update prod_dba.itm_tip_prm
set    itpr_val = '\\heisenberg301\oracleio\faturamento\boleto\'
where  itpr_tipp_cod = 81; 

update prod_dba.itm_tip_prm
set    itpr_val = '\\heisenberg301\oracleio\faturamento\nota_fiscal\'
where  itpr_tipp_cod = 80;

update prod_dba.itm_tip_prm
set    itpr_val = '\\heisenberg301\oracleio\master_cheque\'
where  itpr_tipp_cod = 83;

commit;

alter trigger prod_dba.a413260p disable;
alter trigger PROD_DBA.A413210P disable;
alter trigger PROD_DBA.A413250P disable;
update PROD_DBA.TMP_M100011T set USRA_SNH = 'SENHA123' where USRA_SNH is not null;
update PROD_DBA.USR_AMB set USRA_SNH = 'SENHA123' where USRA_SNH is not null;
update PROD_DBA.CDS_EDR set CDSE_EML = 'n@sodexhopass.com.br' where CDSE_EML is not null;
update PROD_DBA.CDS_LGR set CDSL_EML = 'n@sodexhopass.com.br' where CDSL_EML is not null;
update PROD_DBA.CDS_PSS_FSC set CDSF_EML = 'n@sodexhopass.com.br' where CDSF_EML is not null;
update PROD_DBA.CLI_GST_VND set CGVN_RSP_PDD_EML = 'n@sodexhopass.com.br' where CGVN_RSP_PDD_EML is not null;
update PROD_DBA.CTL_LIG set CTLI_EML = 'n@sodexhopass.com.br' where CTLI_EML is not null;
update PROD_DBA.CTL_LIG_JN set CTLI_EML = 'n@sodexhopass.com.br' where CTLI_EML is not null;
update PROD_DBA.CTT_CLI_ANT set COCL_EML = 'n@sodexhopass.com.br' where COCL_EML is not null;
update PROD_DBA.EDR_GST_VND set EGVN_CTT_EML = 'n@sodexhopass.com.br' where EGVN_CTT_EML is not null;
update PROD_DBA.EML_CMC set ECMC_EML_CC = 'n@sodexhopass.com.br' where ECMC_EML_CC is not null;
update PROD_DBA.EML_CMC set ECMC_EML_DES = 'n@sodexhopass.com.br' where ECMC_EML_DES is not null;
update PROD_DBA.EML_CTT_ADM set EMCA_COD_EML = 'n@sodexhopass.com.br' where EMCA_COD_EML is not null;
update PROD_DBA.EML_CTT_ADM set EMCA_RSP_EML = 'n@sodexhopass.com.br' where EMCA_RSP_EML is not null;
update PROD_DBA.EML_CTT_ADM set EMCA_UND_EML = 'n@sodexhopass.com.br' where EMCA_UND_EML is not null;
update PROD_DBA.HST_CDS_EDR set HSCE_CDSE_EML = 'n@sodexhopass.com.br' where HSCE_CDSE_EML is not null;
update PROD_DBA.HST_CDS_PSS_FSC set HCPF_CDSF_EML = 'n@sodexhopass.com.br' where HCPF_CDSF_EML is not null;
update PROD_DBA.PCAD_CDS_EDR set PCAD_CDSE_EML = 'n@sodexhopass.com.br' where PCAD_CDSE_EML is not null;
update PROD_DBA.PCAD_CTT set PCAD_CDSF_EML = 'n@sodexhopass.com.br' where PCAD_CDSF_EML is not null;
update PROD_DBA.PDD_CLI_SAP set PCSA_EML_DTT = 'n@sodexhopass.com.br' where PCSA_EML_DTT is not null;
update PROD_DBA.PRE_CDS_EDR set PRCE_EML = 'n@sodexhopass.com.br' where PRCE_EML is not null;
update PROD_DBA.PRE_CTT set PRCT_EML = 'n@sodexhopass.com.br' where PRCT_EML is not null;
update PROD_DBA.USR set USR_EML = 'n@sodexhopass.com.br' where USR_EML is not null;
commit;
alter trigger prod_dba.a413260p enable;
alter trigger PROD_DBA.A413210P enable;
alter trigger PROD_DBA.A413250P enable;

update dcjava_config set host = '10.55.4.161';
update DCTCS_CONFIG  set host = '10.55.4.161';

commit;

alter profile IT_SODEXHO limit LOGICAL_READS_PER_CALL unlimited;
spool off;
