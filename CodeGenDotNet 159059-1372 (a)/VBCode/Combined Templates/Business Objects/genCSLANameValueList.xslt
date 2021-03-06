<?xml version="1.0" encoding="UTF-8" ?>
<!--
  ====================================================================
   Copyright ©2004, Kathleen Dollard, All Rights Reserved.
  ====================================================================
   I'm distributing this code so you'll be able to use it to see code
   generation in action and I hope it will be useful and you'll enjoy 
   using it. This code is provided "AS IS" without warranty, either 
   expressed or implied, including implied warranties of merchantability 
   and/or fitness for a particular purpose. 
  ====================================================================
  Summary: Generates the plumbing class for name/value pairs !-->

<xsl:stylesheet version="1.0" 
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
			xmlns:xs="http://www.w3.org/2001/XMLSchema"
			xmlns:dbs="http://kadgen/DatabaseStructure" 
			xmlns:orm="http://kadgen.com/KADORM.xsd" >
<xsl:output method="text" encoding="UTF-8" indent="yes"/>
<xsl:preserve-space elements="*" />

<xsl:param name="Name"/>
<xsl:param name="filename"/>
<xsl:param name="database"/>
<xsl:param name="gendatetime"/>

<xsl:template match="/">
	<xsl:apply-templates select="//orm:Object[@Name=$Name]" 
								mode="Object"/>
</xsl:template>

<xsl:template match="orm:Object" mode="Object">
Option Explicit On
Option Strict On

Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports CSLA.Data
Imports CSLA

&lt;Serializable()> _
Public Class gen<xsl:value-of select="$Name"/>
  Inherits NameValueList
  
  Private Shared m<xsl:value-of select="@Name"/> As <xsl:value-of select="@Name"/> 
  <xsl:call-template name="SharedMethods"/>
  <xsl:call-template name="Constructors"/>
  <xsl:call-template name="Criteria"/>
  <xsl:call-template name="DataAccess"/>
End Class
</xsl:template>

<xsl:template name="SharedMethods">
#Region " Shared Methods "
  Public Shared Function CachedList() As <xsl:text/>
				<xsl:value-of select="$Name"/>
    If m<xsl:value-of select="@Name"/> Is Nothing Then
		m<xsl:value-of select="@Name"/> = GetList()
    End If
    Return m<xsl:value-of select="@Name"/>
  End Function  

  Public Shared Function GetList() As <xsl:text/>
				<xsl:value-of select="$Name"/>
    m<xsl:value-of select="@Name"/> = <xsl:text/>
         <xsl:text/>CType(DataPortal.Fetch(New Criteria()),<xsl:value-of select="@Name"/>)
    Return m<xsl:value-of select="@Name"/>
  End Function

#End Region
</xsl:template>

<xsl:template name="Constructors">
#Region " Constructors "

  Shared Sub New()
    m<xsl:value-of select="@Name"/> = <xsl:value-of select="@Name"/>.GetList()
  End Sub

  Protected Sub New()
    ' prevent direct instantiation
    MyBase.New
  End Sub

  ' this constructor overload is required because
  ' the base class (NameObjectCollectionBase) implements
  ' ISerializable
  Private Sub New( _
        ByVal info As System.Runtime.Serialization.SerializationInfo, _
        ByVal context As System.Runtime.Serialization.StreamingContext)
    MyBase.New(info, context)
  End Sub

#End Region
</xsl:template>

<xsl:template name="Criteria">
#Region " Criteria "
  <!-- You have to escape any less than signs that you want in the output -->
  &lt;Serializable()> _
  Private Class Criteria
	Inherits CSLA.Server.CriteriaBase
	<xsl:call-template name="PrimaryKeyDeclarations"/>

    Public Sub New(<xsl:call-template name="PrimaryKeyArguments"/>)<xsl:text/>
    	MyBase.New(GetType(<xsl:value-of select="$Name"/>))
		<xsl:for-each select="orm:Property[@IsPrimaryKey='true']">
		Me.<xsl:value-of select="@Name"/> = <xsl:value-of select="@Name"/>
		</xsl:for-each>
    End Sub
  End Class

#End Region
</xsl:template>

<xsl:template name="DataAccess">
#Region " Data Access "
 
  <xsl:if test="orm:Privilege[contains(@Rights,'R')]">
  ' called by DataPortal to load data from the database
  Protected Overrides Sub DataPortal_Fetch(ByVal Criteria As Object)
    SimpleFetch(<xsl:value-of select="@MapDataStructure"/>, <xsl:text>
				</xsl:text><xsl:value-of select="@MapTable"/>, <xsl:text>
				</xsl:text><xsl:value-of select="orm:Property[1]"/>, <xsl:text>
				</xsl:text><xsl:value-of select="orm:Property[2]"/>)
  End Sub
  </xsl:if>
#End Region
</xsl:template> 

<!-- Repeated from CSLAEditRoot -->
<xsl:template name="PrimaryKeyDeclarations">
  <xsl:for-each select="orm:Property[@IsPrimaryKey='true']">
		<xsl:variable name="name" select="@Name"	 />
		<xsl:variable name="keytype" select="@NETType"	 />
    Public <xsl:value-of select="$name"/> As <xsl:value-of select="$keytype"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="PrimaryKeyArguments">
  <xsl:for-each select="orm:Property[@IsPrimaryKey='true']">
		<xsl:variable name="name" select="@Name"	 />
		<xsl:variable name="keytype" select="@NETType"	 />
		<xsl:text/>ByVal <xsl:value-of select="$name"/> As <xsl:value-of select="$keytype"/>
		<xsl:if test="position()!=last()">, _
		</xsl:if>
  </xsl:for-each>
</xsl:template>




</xsl:stylesheet> 
  