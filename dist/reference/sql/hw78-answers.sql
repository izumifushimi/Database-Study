-- 上机 7–8 · 存储过程与函数：MySQL 8.0.16+
-- 按题块执行；先载入对应数据集，不同数据集使用各自数据库。

-- 1. 基建 1 · 按项目名称统计材料种数
-- 数据集：construction
DELIMITER //
CREATE PROCEDURE project_material_count(IN p_project_name VARCHAR(60))
BEGIN
  DECLARE v_count INT;
  IF EXISTS(SELECT 1 FROM projects WHERE p_name=p_project_name) THEN
    SELECT COUNT(DISTINCT pr.pr_m_number) INTO v_count
    FROM projects p LEFT JOIN provides pr ON pr.pr_p_number=p.p_number
    WHERE p.p_name=p_project_name;
    SELECT CONCAT(p_project_name,'项目共需要',v_count,'种原材料') AS message;
  ELSE
    SELECT CONCAT(p_project_name,'项目还没有记录') AS message;
  END IF;
END //
DELIMITER ;
CALL project_material_count('南京甲');

-- 2. 基建 2 · 返回项目原材料信息
-- 数据集：construction
DELIMITER //
CREATE FUNCTION project_material_info(p_project_name VARCHAR(60),p_material_name VARCHAR(60))
RETURNS JSON READS SQL DATA
BEGIN
  DECLARE v_result JSON;
  SELECT JSON_ARRAYAGG(JSON_OBJECT(
    '项目名',p.p_name,'原材料名',m.m_name,
    '原材料单价',m.m_price,'供应商',pr.pr_s_number,'供应数量',pr.pr_count
  )) INTO v_result
  FROM projects p JOIN provides pr ON pr.pr_p_number=p.p_number
  JOIN materials m ON m.m_number=pr.pr_m_number
  WHERE p.p_name=p_project_name AND m.m_name=p_material_name;
  RETURN COALESCE(v_result,JSON_ARRAY());
END //
DELIMITER ;
SELECT project_material_info('南京甲','原材料A');

-- 3. 电商 1 · 商品名称模糊查询供应商
-- 数据集：ecommerce
DELIMITER //
CREATE PROCEDURE find_suppliers(IN p_keyword VARCHAR(60))
BEGIN
  DECLARE v_count INT;
  SELECT COUNT(DISTINCT s.s_id) INTO v_count
  FROM suppliers s JOIN products p ON p.s_id=s.s_id
  WHERE p.p_name LIKE CONCAT('%',p_keyword,'%');
  IF v_count>0 THEN
    SELECT CONCAT('共找到',v_count,'个供应商提供',p_keyword,'商品!') AS message;
  ELSE
    SELECT CONCAT('没有供应商提供',p_keyword,'商品') AS message;
  END IF;
END //
DELIMITER ;
CALL find_suppliers('手机');

-- 4. 电商 2 · 购物车按加入时间降序
-- 数据集：ecommerce
DELIMITER //
CREATE PROCEDURE show_cart(IN p_user_id INT)
BEGIN
  SELECT p.p_id,p.p_name,p.price,c.quantity,c.added_at
  FROM cart c JOIN products p ON p.p_id=c.p_id
  WHERE c.u_id=p_user_id
  ORDER BY c.added_at DESC,c.p_id ASC;
END //
DELIMITER ;
CALL show_cart(1);
