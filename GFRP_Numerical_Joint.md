基于Abaqus的退役风电叶片GFRP与双相不锈钢的连接节点模拟
（All content from Frank Lai）

Introduction：Frank的课题研究是关于风电退役叶片的GFRP材料与双相不锈钢材料的连接节点研究。研究层级分为两级，首先是双搭接节点，即一块GFRP板被两块双相不锈钢（Duplex Stainless Steel）双搭接，采用纯胶粘连接、纯螺栓连接以及胶栓混合连接的形式；其次是单搭接节点（同样是三种连接形式的研究）。目前Frank的实际实验已经完成了双搭接部分，正在做双搭接的有限元模拟，然后是做单搭接的模拟以及单搭接的实验。

这里有所区别，因为双搭接在理想状态下是对称的纯剪切状态，因此不会产生剥离应力，所以从Frank目前的实验结果来看胶粘连接的极限强度并未由纯胶粘连接因为加入螺栓后得到增强，而且荷载-位移曲线几乎一致，同时通过改变混合连接的端距也并未看到改变（不同端距也是同样的搭接面积即粘胶面积），但若以纯螺栓连接为基准，加入胶层后一方面提高了连接的初始刚度以及极限荷载，但是同时破坏的位移也被缩短。因此，这些疑问Frank无法通过观察实验结果去判断，需要用abaqus做有限元模拟解释其原理。这里隐藏几个问题，首先Frank明确，三类连接组的搭接面积保持一致（引入栓的打孔面积忽略），且混合连接设置三个端距变量，而采用最大的端距与栓接保持一致，在结果中端距的变化没有对曲线改变，这也是Frank需要做模拟去探究的原因。所以目前的策略是：先模拟做出纯胶粘连接的模型，其次是螺栓连接，最后是混合连接，然后把混合连接进行端距改变得到三个模型，一共是5个模型，至少纯胶粘连接与纯螺栓连接都要符合其实验曲线，然后在混合连接中看模拟的曲线与实验的有何区别。

双搭接实验的曲线如图：[纯胶粘连接与纯螺栓连接](Experiment_Curve_1.png). 以及[混合连接曲线](Experiment_Curve_2.png)

另一方面，在双搭接模拟完成之后，在单搭接实验开始之前，Frank希望可以也基于双搭接模型的材料属性参数去构建好单搭接模型，这样对于后续分析可以加速，也更快有产出。

所有模型完成校对之后就可以进行胶层厚度、螺栓端距、搭接面积等进行改变，去探究更深入更广泛的研究。

至此，2026年4月234日，Frank将重点探讨在abaqus模拟双搭接节点遇到的问题：

1.模拟方法概述，首先胶层采用Cohesive单元（即CZM模型），因为实际的使用的胶是 Araldite® 2015-1.在一下文献中有提到这类胶一般采用三角形的CZM模型：
    1.Modelling adhesive joints with cohesive zone models: effect of the cohesive law shape of the adhesive layer. DOI: 10.1016/j.ijadhadh.2013.02.006. Website: https://linkinghub.elsevier.com/retrieve/pii/S0143749613000353.
    2.Damage detection in adhesively bonded single lap joints by using backface strain: Proposing a new position for backface strain gauges DOI: https://doi.org/10.1016/j.ijadhadh.2019.102494.
    3.Mode I fracture R-curve and cohesive law of CFRP composite adhesive joints. DOI: https://doi.org/10.1016/j.ijadhadh.2022.103102.
其次，GFRP是通过VUMAT子程序，采用Hashin准则进行模拟，具体的Hashin准则的inp文件在[查看完整.for文件](01_hashin_backup.for)，还有一些参考文献如下：
    1.A constitutive model for anisotropic damage in fiber-composites.
    2.Failure Criteria for Unidirectional Fiber Composites.
    3.Modified Hashin criteria based 3D damage progression in bolted, bonded and hybrid single-lap joints of woven GFRP laminates.
    4.[该for文件的指南](3D_HASHIN.pdf)
然后，关于DSS与Bolt的模拟就很简单，输入基本的属性，不锈钢也不需要塑性信息，因为一直处于弹性状态，研究重点在于GFRP的破坏形式，而Bolt需要加入一些预紧力的属性。

2.材料参数：
    [螺栓属性](Bolt_Property.png)
    [DSS属性](DSS_Property.png)
    [GFRP属性](GFRP_Property.png)
    [Cohesive属性](Cohesive_Property.png)
