-- 租金、物管 收入（合同口径）
select t1.project_id,                                                                                -- 项目id
       bas_project.project_name,                                                                     -- 项目名称
       bas_project.project_type,                                                                     -- 经营类型(1001:购物中心 1002:商业街 1003:写字楼 1004：轻资产)
       bas_project.project_name_short,                                                               -- 项目简称
       bas_project.region_id,                                                                        -- 区域id
       bas_region.region_name,                                                                       -- 区域名称
       t1.fee_type,                                                                                  -- 费项类型(1001:租金 1002:物管 1003:保证金 1004:滞纳金 1005:能耗 1006:暂收款 1007:多经)
       if(t1.receivable_date is null, t1.receivable_date, concat_ws('-', t1.receivable_date, '01')), -- 应收月
       t1.receivable_amount,                                                                         -- 应收金额
       t1.sub_amount,                                                                                -- 减免金额
       t1.tenant_name,                                                                               -- 商家名称
       t1.tenant_id,                                                                                 -- 商家id
       t1.cont_id,                                                                                   -- 合同id
       t1.cont_no,                                                                                   -- 合同号
       t1.id,                                                                                        -- 应收id
       current_date                                                                                  -- ETL时间
from (
         select fin_receivable.project_id,                                      -- 项目id
                fin_basic_fee.fee_type,                                         -- 费项类型(1001:租金 1002:物管 1003:保证金 1004:滞纳金 1005:能耗 1006:暂收款 1007:多经)
                substr(fin_receivable.receivable_time, 0, 7) receivable_date,   -- 应收月
                sum(fin_receivable.receivable_amount)        receivable_amount, -- 应收金额
                sum(fin_receivable.sub_amount)               sub_amount,        -- 减免金额
                fin_receivable.tenant_name,                                     -- 商家名称
                fin_receivable.tenant_id,                                       -- 商家id
                fin_receivable.cont_id,                                         -- 合同id
                fin_receivable.cont_no,                                         -- 合同号
                fin_receivable.id                                               -- 应收id
         from ods.ods_bc_yw_pms_business_db_fin_receivable_dt fin_receivable
                  left join ods.ods_bc_yw_pms_business_db_fin_basic_fee_dt fin_basic_fee
                            on fin_receivable.fee_id = fin_basic_fee.id and fin_basic_fee.is_deleted = '0'
                  left join ods.ods_bc_yw_pms_business_db_fin_received_ver_item_dt fin_received_ver_item
                            on fin_receivable.id = fin_received_ver_item.receivable_id and
                               fin_received_ver_item.is_deleted = '0'
                  left join ods.ods_bc_yw_pms_business_db_fin_received_ver_dt fin_received_ver
                            on fin_received_ver_item.received_ver_id = fin_received_ver.id and
                               fin_received_ver.is_deleted = '0'
         where fin_receivable.is_deleted = '0'
           and fin_receivable.is_to_push = '1001'
         group by fin_receivable.id,
                  fin_receivable.project_id,
                  fin_receivable.tenant_id,
                  fin_receivable.tenant_name,
                  fin_receivable.cont_id,
                  fin_receivable.cont_no,
                  fin_basic_fee.fee_type,
                  substr(fin_receivable.receivable_time, 0, 7) -- 应收月

     ) t1
         left join ods.ods_bc_yw_pms_business_db_bas_project_dt bas_project
                   on t1.project_id = bas_project.id and bas_project.is_deleted = '0'
         left join ods.ods_bc_yw_pms_business_db_bas_region_dt bas_region
                   on bas_project.region_id = bas_region.id and bas_region.is_deleted = '0'
         left join ods.ods_bc_yw_pms_business_db_bas_city_dt bas_city
                   on bas_project.city_id = bas_city.id and bas_city.is_deleted = '0'