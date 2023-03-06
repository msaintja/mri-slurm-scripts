
args=(commandArgs(trailingOnly = TRUE))

##args is now a list of character vectors
## First check to see if arguments are passed.
## Then cycle through each element of the list and evaluate the expressions.
if(length(args) != 2){
    stop("Script requires datasetDir, dataset_name arguments")
}

datasetDir <- args[1]
dataset_name <- args[2]

packages <- c("caret", "corrplot", "gbm", "plyr", "randomForest", "e1071",
            "pROC", "DMwR","dplyr","pbkrtest","car","pbkrtest","doParallel","ROSE","repmis", "plotly", "r2d3")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
install.packages(setdiff(packages, rownames(installed.packages())))  
}
lapply(packages, library, character.only = TRUE)

readAseg <- function(){
# The Aseg file of a subject is read in
# Volume_mm3 and StructName are selected
aseg_file <- data.frame(read.table(paste("./stats/aseg.stats", sep=""), row.names=1))[,c(3,4)] 
asegTable <- t(data.frame(aseg_file[,1], row.names = aseg_file[,2])) # Aseg file - regular
return (asegTable)
}

readMetaAseg <- function(){
# The Aseg file of a subject is read in
# Its metadata containing 'lhCortex' etc. and their volume are saved
aseg_meta <- readLines("./stats/aseg.stats", n=35)[14:35]
meta1 <- gsub("# ", "", aseg_meta)
meta <- t(data.frame(strsplit(meta1, ",")))[,c(2,4)]
metaTable <- t(data.frame(meta[,2]))
colnames(metaTable) <- meta[,1]
return(metaTable)
}

editCol <- function(side, string, add){
# Change measure areas from 'Areaname'--> 'lh_Areaname_area'
return(paste(side, "_", string, add, sep=""))
}

readAparc <- function(value){
# Aparc files of lh and rh are read in and the  area and thickness values of both files are retreved as well 
    # as the metadata measurements of both parts
# Areanames are formatted and eventually the data is saved into a data frame
sides <- c("lh", "rh")
ifelse((value == "area"), pos <- 1, pos <- 2)

for (x in 1:length(sides)){
    areaThickness <- as.data.frame(read.table(paste("./stats/", sides[x], ".aparc.stats", sep=""), row.names=1))[, c(2,4)]
    rowValues <- rownames(areaThickness)
    
    meta <- readLines(paste("./stats/", sides[x], ".aparc.stats", sep=""))[c(20, 21)] 
    meta1 <- gsub("# ", "", meta)
    meta2 <- t(data.frame(strsplit(meta1, ",")))[, c(2,4)]
    meta3 <- data.frame(meta2[pos,2])
    value2 <- gsub(" ", "", meta2[pos,1])
    
    colnames(meta3) <- paste(sides[x], "_", value2, "_" , value, sep="")
    extra <- t(matrix(areaThickness[,pos]))
    colnames(extra) <- paste(sides[x], "_", rowValues, "_", value, sep="")
    ifelse(x==1, aparcTable <- cbind(extra, meta3), aparcTable <- cbind(aparcTable, extra, meta3))
}
return(aparcTable)
}

readFiles <- function(){
# Aseg and Aparc files are read in and all the data is merged, starting with Aseg data followed with Aparc
asegTable <- readAseg()
metaTable <- readMetaAseg()

areaAparc <- readAparc("area")
thickAparc <- readAparc("thickness")

subjectTable <- cbind(asegTable, metaTable, areaAparc, thickAparc) # aparcMeta --> WhiteSurface
subjectTable <- data.frame(subjectTable)
return (subjectTable)
}

preprocTable <- function(subjectTable){
# Columnames are edited or removed from the table
removeCols <- c("*.WM-hypointensities$","*.WM.hypointensities$", "*pole*", "*bankssts*", "VentricleChoroidVol", "*CerebralWhiteMatterVol", "\\bSurfaceHoles\\b",
                "SegVolFile.mri.aseg.mgz.", "*CorticalWhiteMatterVol")
remove <- grep(paste(removeCols, collapse="|"), colnames(subjectTable))
subjectTable <- subjectTable[, -remove]

colnames(subjectTable) <- gsub("^X\\.", "", colnames(subjectTable))
colnames(subjectTable) <- gsub("_\\.", "_", colnames(subjectTable))
colnames(subjectTable) <- gsub("-", ".", colnames(subjectTable))
colnames(subjectTable) <- gsub(" ", "", colnames(subjectTable))

colnames(subjectTable)[which(colnames(subjectTable) == "eTIV")] <- "EstimatedTotalIntraCranialVol"
colnames(subjectTable)[which(colnames(subjectTable) %in% c("rd.Ventricle", "th.Ventricle", 
                                                            "5th.Ventricle"))] <- c("X4th.Ventricle", "X3rd.Ventricle", "X5th.Ventricle") # change to names

return(subjectTable)
}

main <- function(){
# It loops through all subjects sub-directories in the given directory
# With every single subject, data is retrieved and written in a row in the final table. 
# The result is saved into a .CSV file
subjects <- c()
first <- T
subjectDirs <- unique(list.dirs('.', recursive=FALSE)) # Get all sample subject
subjectDirs <- subjectDirs[startsWith(subjectDirs, "./sub-") | startsWith(subjectDirs, "sub-")]

for (x in 1:length(subjectDirs)){
    setwd(paste(datasetDir, subjectDirs[x], sep=""))
    statsDirs <- list.dirs('.', recursive=FALSE)
    if (file.exists("./stats/aseg.stats")){
    subjectTable <- readFiles()
    subjectTable <- preprocTable(subjectTable)
    if (first == T){
        stats2Table <- subjectTable
        subjects <- c(subjects, substring(subjectDirs[x], 3))
        first = F
    } 
    else if (ncol(subjectTable) == ncol(stats2Table)&& (first == F)){
        stats2Table <- rbind(stats2Table, subjectTable)
        subjects <- c(subjects, substring(subjectDirs[x], 3))
    } 
    
    }
}

stats2Table <- data.frame(stats2Table)
stats2Table <- cbind(subjects, stats2Table) 
colnames(stats2Table)[1] <- "participant_id"  
setwd(datasetDir)
dir.create(file.path("..", "qoala"), showWarnings = FALSE)

write.csv(stats2Table, paste("FreeSurfer_Output_", dataset_name,".csv", sep=""), row.names = FALSE)
    }
main()
read.csv(paste("FreeSurfer_Output_",dataset_name,".csv", sep=""))
stats2Table <- read.csv(paste("FreeSurfer_Output_", dataset_name, ".csv", sep=""), header=T, row.names=1)
test_data <- stats2Table

githubURL <- "https://github.com/Qoala-T/QC/blob/master/Qoala_T_model.Rdata?raw=true"
rf.tune <- get(load(url(githubURL)))

# -----------------------------------------------------------------
#reorder colnames of dataset to match traningset
# -----------------------------------------------------------------
dataset_colnames <- names(rf.tune$trainingData)[-ncol(rf.tune$trainingData)]
testing <- test_data[,dataset_colnames]
testing <- testing[complete.cases(testing),]

# -----------------------------------------------------------------
## External validation of unseen data on Qoala-T model 
# -----------------------------------------------------------------
rf.pred <-  predict(rf.tune,testing)
rf.probs <- predict(rf.tune,testing,type="prob") # probability of belonging in either category (certainty..)

# -----------------------------------------------------------------
# Saving output
# ----------------------------------------------------------------
# create empty data frame
Qoala_T_predictions <- data.frame(matrix(ncol = 4, nrow = nrow(rf.probs)))                             
colnames(Qoala_T_predictions) = c('participant_id','Scan_QoalaT', 'Recommendation', 'manual_QC_adviced') 

# fill data frame
Qoala_T_predictions$participant_id <- row.names(rf.probs)
Qoala_T_predictions$Scan_QoalaT <- rf.probs$Include*100 
Qoala_T_predictions$qoala_prob <- 1.0-rf.probs$Include
Qoala_T_predictions$Recommendation <- rf.pred
Qoala_T_predictions$manual_QC_adviced <- ifelse(Qoala_T_predictions$Scan_QoalaT<70&Qoala_T_predictions$Scan_QoalaT>30,"yes","no")
Qoala_T_predictions <- Qoala_T_predictions[order(Qoala_T_predictions$Scan_QoalaT, Qoala_T_predictions$participant_id),]


csv_Qoala_T_predictions = '../qoala/qc.csv'
write.csv(Qoala_T_predictions, file = csv_Qoala_T_predictions, row.names=F)
read.csv(csv_Qoala_T_predictions)
excl_rate <- table(Qoala_T_predictions$Recommendation)

fill_colour <- rev(c("#256da8","#CF4A30"))
font_size <- 12
text_col <- "Black"

p <- ggplot(Qoala_T_predictions, aes(name = participant_id, x=Scan_QoalaT,y=1,col=Recommendation)) +  
annotate("rect", xmin=30, xmax=70, ymin=1.12, ymax=.88, alpha=0.2, fill="#777777") +
geom_jitter(alpha=.8,height=.1,size=5) +
ggtitle(paste("Qoala-T estimation model based for ",dataset_name,"\nMean Qoala-T Score = ",round(mean(Qoala_T_predictions$Scan_QoalaT),1),sep="")) + 
annotate("text", x=20, y=1.15, label=paste("Excluded = ",as.character(round(excl_rate[1]))," scans",sep="")) + 
annotate("text", x=80, y=1.15, label=paste("Included = ",as.character(round(excl_rate[2]))," scans",sep="")) + 
scale_colour_manual(values=fill_colour) +
theme_bw() +
theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.border = element_blank(),
        axis.text.x = element_text (size = font_size,color=text_col),
        axis.text.y = element_blank(),
        axis.title.x = element_text (size = font_size,color=text_col), 
        axis.title.y = element_blank(), 
        axis.ticks=element_blank(),
        plot.title=element_text (size =16,color=text_col,hjust=.5)
)
print(p)

filename<- paste("../qoala/Figure_Rating_model_based_",dataset_name,".pdf",sep="")
dev.copy(pdf,filename,width=30/2.54, height=20/2.54)
dev.off()
