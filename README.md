<p>&nbsp;</p>
<h2><a id="user-content-what-is-this-repository-for" class="anchor" href="https://github.com/srp33/TCGA_RNASeq_Clinical#what-is-this-repository-for" aria-hidden="true"></a>SuicideNetwork: Network-based analysis to predict and understand suicide fatality</h2>
<ul>
<li>Authors of source code: <a href="mailto:hyojungpaik@gmail.com,">hyojungpaik@gmail.com,</a>&nbsp;<a href="mailto:polord@gmail.com ">polord@gmail.com </a></li>
<li>Current version of the project: ver. 0.1</li>
</ul>
<p>&nbsp;</p>
<h3>Prerequisites</h3>
<ol>
<li>R version 3.3.2 -- "Sincere Pumpkin Patch"</li>
<li>Python version 2.7.15</li>
<li>Tensorflow version 1.8.0</li>
<li>Data of ours in matrix format.</li>
</ol>
<h3>License</h3>
<p>The development of source codes are funded by National Supercomputing Center included resources and technology (K-18-L-12-C08-S01, KAT GPU cluster system) and the Korea Institute of Science and Technology Information (KISTI) (K-17L03-C02-S01, P-18-SI-CT-1-S01). Use of source codes are free for academic researchers. However, the users of source codes from the private sector will need to contact to the developers of the project.</p>
<h3>Patent</h3>
<p>The development of source codes are funded by National Supercomputing Center included resources and technology (K-18-L-12-C08-S01, KAT GPU cluster system) and the Korea Institute of Science and Technology Information (KISTI) (K-17L03-C02-S01, P-18-SI-CT-1-S01). Use of source codes are free for academic researchers. However, the users of source codes from the private sector will need to contact to the developers of the project.</p>
<h3>CAVEAT</h3>
<p>We present the source codes as an example of our research project to help a user who has a little background of computational analysis.</p>
<h3>How to use</h3>
<p>This project consists of three steps.</p>
<p>&lt;Step 0&gt;: see the folder "DataProcessing"</p>
<p>&nbsp; &nbsp; &nbsp; 0-0. preprocessing of data (e.g. conversion date into numeric value based on the method of KSP data format)</p>
<p>&nbsp; &nbsp; &nbsp; 0-1. KNN imputation for missing values</p>
<p>&nbsp; &nbsp; &nbsp; 0-2. Data split into train and test data for 10-fold cross validation</p>
<p>&lt;Step 1&gt;: see the folder "EGONet"</p>
<p>&nbsp; &nbsp; &nbsp; 0-0. Generation of the relationship reinforced features</p>
<p>&nbsp; &nbsp; &nbsp; 0-1. Train and test of EGONet</p>
<p>&lt;Step 2&gt;: see the folder "Benchmarking_model"</p>
<p>&nbsp; &nbsp; &nbsp; 0-0. Train and test of other machine learning models including linear regression and random forest.</p>
<p>&nbsp;</p>
<h2><a id="user-content-contact-information" class="anchor" href="https://github.com/srp33/TCGA_RNASeq_Clinical#contact-information" aria-hidden="true"></a>Contact information</h2>
<ul>
<li>Hyojung Paik.&nbsp;<a href="mailto:hyojungpaik@gmail.com,">hyojungpaik@gmail.com</a></li>
<li>Younghoon Kim.&nbsp;<a href="mailto:polord@gmail.com ">polord@gmail.com</a></li>
</ul>
