# Softmax Function Approximation Comparison

## I. Experimental Results in Paper

![Softmax_test](./Pictures/Softmax_test.png)

First, [[1]](#vi-references) shows the results of such experiments.  
The paper compares the end-to-end accuracy of BERT-base across various NLP datasets.  
It uses PyTorch with FP32 and ideal implementations of Softmax and GELU as the Baseline.  
Against this baseline, it measures the accuracy loss when replacing these operations with low-complexity approximations using shift/add and LUTs.  

[[1]](#vi-references) shows that even when the entire model is replaced with these approximate operations, the overall accuracy loss across multiple GLUE benchmark tasks remains very small (maximum 0.24%).

## II. Reproducing the Experimental Results

Here, I perform a simplified experiment to test the impact of Softmax approximation on classification accuracy, similar in [[1]](#vi-references).  
While [[1]](#vi-references) replaces the entire model with approximate operations and conducts end-to-end training and inference,  
this experiment only takes the logits output from an already fine-tuned BERT model and swaps out the Softmax computation.  

I use 872 validation sentences from the SST-2 dataset, which is available via the **Hugging Face Datasets library**,  
and obtain logits using a publicly available BERT model from Hugging Face that has been fine-tuned on SST-2. 

These logits are then passed through two different Softmax implementations:  
- PyTorch’s FP32-precision Softmax (baseline)  
- The approximate Softmax

I compare the classification results between these two methods.


## III. get_SST2_BERT_logits

This function runs the SST-2 validation dataset through a fine-tuned BERT model to obtain logits and true labels.

This function loads the 872 validation sentences from the SST-2 dataset using the Hugging Face Datasets library.
Then, tokenizes them with the appropriate BERT tokenizer, and performs inference with the 
"textattack/bert-base-uncased-SST-2" model. 
It returns the logits (raw classification scores) and their corresponding ground-truth labels.

### Returns
- logits (numpy.ndarray): The predicted logits for each sentence in the validation set.
- true_labels (numpy.ndarray): The corresponding ground-truth labels for evaluation.

### Code
```py
def get_SST2_BERT_logits():
    # 1. Model Preparation
    model_name = "textattack/bert-base-uncased-SST-2"
    # Model name to load
    tokenizer = BertTokenizer.from_pretrained(model_name)
    # Load the tokenizer compatible with the model
    # Returns a tokenizer object
    model = BertForSequenceClassification.from_pretrained(model_name)
    # Load the BERT model fine-tuned on SST-2
    # Returns a model object

    model.eval()  # Set the model to evaluation mode

    # 2. Load all SST-2 validation samples
    # SST-2 samples are available via Hugging Face
    # Use load_dataset from datasets
    dataset = datasets.load_dataset("glue", "sst2", split="validation")
    # "validation" → loads 872 evaluation samples
    sentences = dataset["sentence"]
    # Sentence samples
    true_labels = np.array(dataset["label"])
    # Ground truth labels

    print(f"Loaded {len(sentences)} SST-2 samples.")
    # Confirm loading of the entire dataset

    # 3. Tokenize sentences
    inputs = tokenizer(sentences, return_tensors="pt", padding=True, truncation=True)
    # Use the loaded tokenizer
    # inputs = {
    #       "input_ids": Tensor1,
    #       "attention_mask": Tensor2
    #   }
    # Tensor1: token ID sequences for each sentence
    # Tensor2: attention mask indicating which tokens are padding (0) vs real (1)
    # Returns a dictionary (Key-Value pairs)

    with torch.no_grad():
        # Disable gradient tracking in this block
        # Turns off autograd engine
        # No backpropagation is performed
        # Used only for inference (prediction)
        outputs = model(
            input_ids=inputs["input_ids"],
            attention_mask=inputs["attention_mask"],
        )
        # outputs = SequenceClassifierOutput(
        #       loss=None (or value),
        #       logits=Tensor,
        #       hidden_states=None,
        #       attentions=None
        #   )
        # logits is a tensor containing predicted score vectors for each sentence
        logits = outputs.logits.numpy()
        # Convert the tensor to a NumPy array

    return [logits, true_labels]
```

## IV. evaluate_SST2_softmax_accuracy

This function evaluates and compares classification accuracy using standard and approximate Softmax on SST-2 validation logits.

This function takes the logits and true labels from get_SST2_BERT_logits(),
applies both the baseline PyTorch FP32 Softmax and the approximate Softmax,
and computes predicted labels for each approach. 
It compares these predictions against the ground-truth labels to measure accuracy. 
Finally, it shows the accuracy of both methods and their label agreement rate.

### Code
```py
def evaluate_SST2_softmax_accuracy():
    logits, true_labels = get_SST2_BERT_logits()
    # Compare predicted labels
    correct_basic = 0
    correct_approx = 0
    match_count = 0

    for idx, logit in enumerate(logits):
        std_probs = baseline_softmax_Pytorch_FP32(logit)
        approx_probs = approx2_softmax(logit)
        std_label = np.argmax(std_probs)
        approx_label = np.argmax(approx_probs)
        true_label = true_labels[idx]

        # Measure accuracy
        # Compare with ground truth
        if std_label == true_label:
            correct_basic += 1
            print("[O", end="")
        else:
            print("[X", end="")

        if approx_label == true_label:
            correct_approx += 1
            print("O]", end="")
        else:
            print("X]", end="")

        if idx % 20 == 19:
            print()

        # Check label agreement between standard and approximate softmax
        if std_label == approx_label:
            match_count += 1

    # Summary of overall accuracy
    total = len(logits)
    acc_basic = correct_basic / total * 100
    acc_approx = correct_approx / total * 100
    label_match_rate = match_count / total * 100

    print("\n=====Evaluation Results=====")
    print(f"Standard Softmax Accuracy : {acc_basic:.3f}% ({correct_basic}/{total})")
    print(f"Approximate Softmax Accuracy: {acc_approx:.3f}% ({correct_approx}/{total})")
    print(
        f"Label Match Rate (Std vs Approx): {label_match_rate:.3f}% ({match_count}/{total})"
    )
```
## V. Result

```
Loaded 872 SST-2 samples.
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO]
[OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][XX][OO][XX][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][XX][OO][OO][XX][OO]
[OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][XX][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][XX][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][XX][OO][XX][OO][OO][OO][OO][OO][OO]
[OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO]
[OO][XX][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX]
[OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][XX][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX]
[XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][XX][OO][XX][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][XX][OO][XX]
[OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][XX][OO][OO][OO]
[OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][XX][OO][XX][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][XX][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
[OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO][OO]
=====Evaluation Results=====
Standard Softmax Accuracy : 92.431% (806/872)
Approximate Softmax Accuracy: 92.431% (806/872)
Label Match Rate (Std vs Approx): 100.000% (872/872)
```
First, there is a difference between the results of this experiment and in [[1]](#vi-references).
In [[1]](#vi-references), accuracy was measured through end-to-end training and inference on a variety of datasets, including SST-2.

In contrast, this experiment used an already fine-tuned BERT model and compared only the Softmax computation step.
This difference in approach is the main reason why the PyTorch baseline accuracy differs from that in the paper.

Additionally, the reason why the baseline Softmax and the approximate Softmax produced identical predictions in this experiment is that,
while [[1]](#vi-references) used a fixed-point (16-bit) implementation that introduces approximation errors,
but this code performed all computations—including Softmax—in FP32 (floating-point) precision.
As a result, the approximate Softmax computation incurred almost no error, leading to identical predictions from both methods.

## VI. References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.